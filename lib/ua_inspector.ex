defmodule UAInspector do
  @moduledoc """
  UAInspector Application
  """

  use Application

  alias UAInspector.Config
  alias UAInspector.Databases
  alias UAInspector.ShortCodeMaps

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: UAInspector.Supervisor ]
    children = [
      worker(Databases, []),
      worker(ShortCodeMaps, []),
      UAInspector.Pool.child_spec
    ]

    sup = Supervisor.start_link(children, options)
    :ok = Config.database_path |> Databases.load()
    :ok = Config.database_path |> ShortCodeMaps.load()

    sup
  end


  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(String.t) :: boolean
  defdelegate bot?(ua), to: UAInspector.Pool

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: map
  defdelegate parse(ua), to: UAInspector.Pool

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t) :: map
  defdelegate parse_client(ua), to: UAInspector.Pool
end
