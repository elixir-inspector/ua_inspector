defmodule UAInspector.Database.OSs do
  @moduledoc """
  UAInspector operating system information database.
  """

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"

  use UAInspector.Database, [
    sources: [{ "", "oss.yml", "#{ @source_base_url }/oss.yml" }]
  ]

  alias UAInspector.Util

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    %{
      name:    data["name"],
      regex:   Util.build_regex(data["regex"]),
      version: data["version"]
    }
  end
end
