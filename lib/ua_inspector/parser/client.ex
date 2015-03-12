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
    version  = v |> to_string() |> Util.to_semver()
     filtered = Enum.filter engines, fn ({ maybe_version, _ }) ->
      maybe_version = maybe_version |> to_string() |> Util.to_semver()

      :lt != Version.compare(version, maybe_version)
     end

    case List.last(filtered) do
      nil           -> default
      { _, ""     } -> nil
      { _, engine } -> engine
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
      |> Util.sanitize_version()
      |> Util.maybe_unknown()
  end
end
