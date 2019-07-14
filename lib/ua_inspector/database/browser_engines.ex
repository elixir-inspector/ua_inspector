defmodule UAInspector.Database.BrowserEngines do
  @moduledoc false

  use UAInspector.Database

  alias UAInspector.Config
  alias UAInspector.Util

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def sources do
    [
      {"", "browser_engine.browser_engine.yml",
       Config.database_url(:browser_engine, "browser_engine.yml")}
    ]
  end

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    {Util.build_regex(data["regex"]), data["name"]}
  end
end
