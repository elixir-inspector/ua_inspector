defmodule UAInspector.Database.OSs do
  @moduledoc false

  use UAInspector.Database,
    ets_prefix: :ua_inspector_db_oss,
    type: :os

  alias UAInspector.Config
  alias UAInspector.Util

  def sources do
    [{"", "os.oss.yml", Config.database_url(:os, "oss.yml")}]
  end

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    %{
      name: data["name"] || "",
      regex: Util.build_regex(data["regex"]),
      version: to_string(data["version"]) || ""
    }
  end
end
