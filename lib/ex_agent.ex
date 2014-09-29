defmodule ExAgent do
  @moduledoc """
  ExAgent Application
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: ExAgent.Supervisor ]
    children = [ worker(ExAgent.Databases, []), ExAgent.Pool.child_spec ]

    sup = Supervisor.start_link(children, options)

    if Application.get_env(:ex_agent, :database_path) do
      :ok = load(Application.get_env(:ex_agent, :database_path))
    end

    sup
  end

  @doc """
  Loads parser databases from given base path.

  Proxy method for `ExAgent.Databases.load/1`.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(path), do: ExAgent.Databases.load(path)

  @doc """
  Parses a user agent.

  Proxy method for `ExAgent.Pool.parse/1`.
  """
  @spec parse(String.t) :: map
  def parse(ua), do: ExAgent.Pool.parse(ua)
end
