defmodule UAInspector.Database.BrowserEngines do
  @moduledoc """
  UAInspector browser engine information database.
  """

  use UAInspector.Database,
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
