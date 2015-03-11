defmodule UAInspector.Parser.Client do
  @moduledoc """
  UAInspector client information parser.
  """

  use UAInspector.Parser

  alias UAInspector.Database.Clients
  alias UAInspector.Parser.BrowserEngine
  alias UAInspector.Result
  alias UAInspector.Util

  def parse(ua), do: parse(ua, Clients.list)


  defp parse(_,  []),                             do: :unknown
  defp parse(ua, [{ _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_data(ua, entry)
    else
      parse(ua, database)
    end
  end


  defp engine_str(nil, _),                      do: nil
  defp engine_str([{ "default", "" }], _),      do: nil
  defp engine_str([{ "default", default }], _), do: default

  defp engine_str([{ "default", default } | [{ "versions", engines }]], v) do
    version =
         v
      |> String.split(".", parts: 2)
      |> hd()
      |> String.to_integer(10)

    filtered = Enum.filter engines, fn ({ maybe_version, _ }) ->
      version >= maybe_version
    end

    case filtered do
      []              -> default
      [{ _, engine }] -> engine
    end
  end


  defp parse_data(ua, entry) do
    version = version_str(ua, entry)
    engine  = engine_str(entry.engine, version)

    %Result.Client{
      engine:  engine || BrowserEngine.parse(ua),
      name:    entry.name,
      type:    entry.type,
      version: version
    }
  end


  defp version_str(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    (entry.version || "")
      |> Util.uncapture(captures)
      |> String.replace(~r/\$(\d)/, "")
      |> String.strip()
      |> String.replace(~r/\.(\d)0+$/, ".\\1")
      |> Util.maybe_unknown()
  end
end
