defmodule UAInspector.Database.BrowserEngines do
  @moduledoc false

  use UAInspector.Database,
    ets_prefix: :ua_inspector_db_browser_engines,
    type: :browser_engine

  alias UAInspector.Config
  alias UAInspector.Util

  def sources do
    [
      {"", "browser_engine.browser_engine.yml",
       Config.database_url(:browser_engine, "browser_engine.yml")}
    ]
  end

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    %{
      name: data["name"],
      regex: Util.build_regex(data["regex"])
    }
  end
end
