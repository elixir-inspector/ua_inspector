defmodule UAInspector.Database.Bots do
  @moduledoc """
  UAInspector bot information database.
  """

  use UAInspector.Database,
    ets_prefix: :ua_inspector_db_bots,
    sources: [{"", "bots.yml"}],
    type: :bot

  alias UAInspector.Util

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    %{
      category: data["category"] || :unknown,
      name: data["name"],
      producer: producer_info(data["producer"]),
      regex: Util.build_regex(data["regex"]),
      url: data["url"] || :unknown
    }
  end

  defp producer_info(nil), do: nil

  defp producer_info(info) do
    info = Enum.into(info, %{})

    %{name: info["name"], url: info["url"]}
  end
end
