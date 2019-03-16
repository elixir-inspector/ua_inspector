defmodule UAInspector.Database.BrowserEngines do
  @moduledoc false

  use UAInspector.Database,
    ets_prefix: :ua_inspector_db_browser_engines,
    sources: [{"", "browser_engine.yml"}],
    type: :browser_engine

  alias UAInspector.Util

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    %{
      name: data["name"],
      regex: Util.build_regex(data["regex"])
    }
  end
end
