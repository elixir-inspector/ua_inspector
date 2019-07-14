defmodule UAInspector.Database.OSs do
  @moduledoc false

  use UAInspector.Database

  alias UAInspector.Config
  alias UAInspector.Util

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def sources do
    [{"", "os.oss.yml", Config.database_url(:os, "oss.yml")}]
  end

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    {
      data["name"] || "",
      Util.build_regex(data["regex"]),
      to_string(data["version"] || "")
    }
  end
end
