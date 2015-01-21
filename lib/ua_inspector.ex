defmodule UAInspector do
  @moduledoc """
  UAInspector Application
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: UAInspector.Supervisor ]
    children = [ worker(UAInspector.Databases, []), UAInspector.Pool.child_spec ]

    sup = Supervisor.start_link(children, options)

    if Application.get_env(:ua_inspector, :database_path) do
      :ok = load(Application.get_env(:ua_inspector, :database_path))
    end

    sup
  end

  @doc """
  Loads parser databases from given base path.

  Proxy method for `UAInspector.Databases.load/1`.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(path), do: UAInspector.Databases.load(path)

  @doc """
  Parses a user agent.

  Proxy method for `UAInspector.Pool.parse/1`.
  """
  @spec parse(String.t) :: map
  def parse(ua), do: UAInspector.Pool.parse(ua)
end
