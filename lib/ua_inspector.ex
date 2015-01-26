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
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  defdelegate load(path), to: UAInspector.Databases

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: map
  defdelegate parse(ua), to: UAInspector.Pool
end
