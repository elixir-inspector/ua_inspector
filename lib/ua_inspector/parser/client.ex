defmodule UAInspector.Parser.Client do
  @moduledoc false

  alias UAInspector.Database.Clients
  alias UAInspector.Parser.BrowserEngine
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, Clients.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{regex, result} | database]) do
    case Regex.run(regex, ua) do
      nil -> parse(ua, database)
      captures -> result(ua, result, captures)
    end
  end

  defp find_engine_version(_, :unknown), do: :unknown

  defp find_engine_version(ua, engine) do
    regex = ~r/#{engine}\s*\/?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$))))/i

    case Regex.run(regex, ua) do
      nil -> :unknown
      [_, version] -> version
    end
  end

  defp maybe_resolve_engine("browser", engine_data, ua, version) do
    engine =
      case resolve_engine(engine_data, version) do
        "" -> BrowserEngine.parse(ua)
        engine -> engine
      end

    Util.maybe_unknown(engine)
  end

  defp maybe_resolve_engine(_, _, _, _), do: :unknown

  defp resolve_engine(nil, _), do: ""
  defp resolve_engine([{"default", default}], _), do: default

  defp resolve_engine([{"default", default}, {"versions", engines}], version) do
    version = version |> to_string() |> Util.to_semver()

    {_, engine} =
      Enum.find(
        engines,
        {nil, default},
        fn {maybe_version, _} ->
          :lt != Version.compare(version, maybe_version)
        end
      )

    engine
  end

  defp resolve_name(name, captures) do
    name
    |> Util.uncapture(captures)
    |> Util.sanitize_name()
    |> Util.maybe_unknown()
  end

  defp resolve_version(version, captures) do
    version
    |> Util.uncapture(captures)
    |> Util.sanitize_version()
    |> Util.maybe_unknown()
  end

  defp result(ua, {engine, name, type, version}, captures) do
    version = resolve_version(version, captures)
    engine = maybe_resolve_engine(type, engine, ua, version)

    %Result.Client{
      engine: engine,
      engine_version: find_engine_version(ua, engine),
      name: resolve_name(name, captures),
      type: type,
      version: version
    }
  end
end
