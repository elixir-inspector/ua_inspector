defmodule UAInspector.Database.BrowserEngines do
  @moduledoc false

  use UAInspector.Database

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
