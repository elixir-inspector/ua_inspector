defmodule ExAgent.Pool do
  @moduledoc """
  Connects the plain ExAgent interface with the underlying pool.
  """

  @pool_name    :ex_agent_pool
  @pool_options [
    name:          { :local, @pool_name },
    worker_module: ExAgent.Server,
    size:          Application.get_env(:ex_agent, :pool_size, 5),
    max_overflow:  Application.get_env(:ex_agent, :pool_max_overflow, 10)
  ]

  @doc """
  Returns poolboy child specification for supervision tree.
  """
  def child_spec(), do: :poolboy.child_spec(@pool_name, @pool_options, [])

  @doc false
  def parse(ua) do
    :poolboy.transaction(
      @pool_name,
      &GenServer.call(&1, { :parse, ua })
    )
  end
end
