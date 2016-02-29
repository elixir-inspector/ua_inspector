defmodule UAInspector.Database.BrowserEngines do
  @moduledoc """
  UAInspector browser engine information database.
  """

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client"

  use UAInspector.Database, [
    sources: [{ "", "browser_engines.yml", "#{ @source_base_url }/browser_engine.yml" }]
  ]

  alias UAInspector.Util

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    %{
      name:  data["name"],
      regex: Util.build_regex(data["regex"])
    }
  end
end
