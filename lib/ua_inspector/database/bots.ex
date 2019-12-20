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

    {
      Util.build_regex(data["regex"]),
      {
        data["category"] || :unknown,
        data["name"],
        data["url"] || :unknown,
        producer_info(data["producer"])
      }
    }
  end

  defp producer_info(nil), do: nil

  defp producer_info(info) do
    info = Enum.into(info, %{})

    {info["name"], info["url"]}
  end
end
