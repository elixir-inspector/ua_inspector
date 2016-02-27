defmodule UAInspector do
  @moduledoc """
  UAInspector Application
  """

  use Application

  alias UAInspector.Config
  alias UAInspector.Databases
  alias UAInspector.ShortCodeMap
  alias UAInspector.ShortCodeMaps

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: UAInspector.Supervisor ]
    children = [
      worker(Databases, []),

      worker(ShortCodeMap.DeviceBrands, []),
      worker(ShortCodeMap.OSs, []),

      UAInspector.Pool.child_spec
    ]

    { :ok, sup } = Supervisor.start_link(children, options)
    :ok          = Config.database_path |> Databases.load()
    :ok          = Config.database_path |> ShortCodeMaps.load()

    { :ok, sup }
  end


  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(String.t) :: boolean
  defdelegate bot?(ua), to: UAInspector.Pool

  @doc """
  Checks if a user agent is a HbbTV and returns its version if so.
  """
  @spec hbbtv?(String.t) :: false | String.t
  defdelegate hbbtv?(ua), to: UAInspector.Pool

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
