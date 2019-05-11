defmodule UAInspector.Database.Bots do
  @moduledoc false

  use UAInspector.Database

  alias UAInspector.Config
  alias UAInspector.Util

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def sources do
    [{"", "bot.bots.yml", Config.database_url(:bot, "bots.yml")}]
  end

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
