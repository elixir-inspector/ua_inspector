defmodule ExAgent.Databases do
  @ets_table :ex_agent

  def init() do
    :ets.new(@ets_table, [ :set, :public, :named_table ])

    ExAgent.Database.Clients.init()
    ExAgent.Database.Devices.init()
    ExAgent.Database.Oss.init()

    :ets.insert(:ex_agent, [ clients: 0, devices: 0, oss: 0 ])
  end

  def load(path) do
    ExAgent.Database.Clients.load(path)
    ExAgent.Database.Devices.load(path)
    ExAgent.Database.Oss.load(path)

    :ok
  end

  def terminate() do
    ExAgent.Database.Clients.terminate()
    ExAgent.Database.Devices.terminate()
    ExAgent.Database.Oss.terminate()

    :ets.delete(@ets_table)
  end

  def update_counter(counter), do: :ets.update_counter(@ets_table, counter, 1)
end
