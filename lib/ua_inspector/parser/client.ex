defmodule UAInspector.Parser.Client do
  @moduledoc false

  alias UAInspector.Database.Clients
  alias UAInspector.Parser.BrowserEngine
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser

  @impl UAInspector.Parser
  def parse(ua), do: parse(ua, Clients.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{regex, result} | database]) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> parse(ua, database)
      captures -> result(ua, result, captures)
    end
  end

  defp find_engine_version(ua, regex) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> :unknown
      ["", version | _] -> version
      [version | _] -> version
    end
  end

  defp maybe_browser_engine("", ua), do: BrowserEngine.parse(ua)
  defp maybe_browser_engine({"", _}, ua), do: BrowserEngine.parse(ua)
  defp maybe_browser_engine(engine, _), do: engine

  defp maybe_resolve_engine("browser", engine_data, ua, version) do
    engine_data
    |> resolve_engine(version)
    |> maybe_browser_engine(ua)
  end

  defp maybe_resolve_engine(_, _, _, _), do: :unknown

  defp resolve_engine(nil, _), do: ""
  defp resolve_engine([{"default", default}], _), do: default
  defp resolve_engine([{"default", default}, _], :unknown), do: default

  defp resolve_engine([{"default", default}, {"versions", engines}], version) do
    version
    |> Util.to_semver()
    |> resolve_engine_detailed(engines, default)
  end

  defp resolve_engine_detailed(_, [], default), do: default

  defp resolve_engine_detailed(version, [{engine_version, engine} | engines], default) do
    if :lt != Version.compare(version, engine_version) do
      engine
    else
      resolve_engine_detailed(version, engines, default)
    end
  end

  defp resolve_name(name, captures) do
    name
    |> Util.uncapture(captures)
    |> String.trim()
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

    {engine, engine_version} =
      case maybe_resolve_engine(type, engine, ua, version) do
        {engine, version_regex} when is_binary(engine) and 0 < byte_size(engine) ->
          {engine, find_engine_version(ua, version_regex)}

        _ ->
          {:unknown, :unknown}
      end

    %Result.Client{
      engine: engine,
      engine_version: engine_version,
      name: resolve_name(name, captures),
      type: type,
      version: version
    }
  end
end
