defmodule UAInspector.Database.OSs do
  @moduledoc """
  UAInspector operating system information database.
  """

  use UAInspector.Database, [
    sources: [{ "", "oss.yml" }],
    type:    :os
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
