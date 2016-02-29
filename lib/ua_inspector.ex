defmodule UAInspector do
  @moduledoc """
  UAInspector Application
  """

  use Application

  alias UAInspector.Config
  alias UAInspector.Database
  alias UAInspector.ShortCodeMap

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: UAInspector.Supervisor ]
    children = [
      worker(Database.Bots, []),
      worker(Database.BrowserEngines, []),
      worker(Database.Clients, []),
      worker(Database.Devices, []),
      worker(Database.OSs, []),
      worker(Database.VendorFragments, []),

      worker(ShortCodeMap.DeviceBrands, []),
      worker(ShortCodeMap.OSs, []),

      UAInspector.Pool.child_spec
    ]

    { :ok, sup } = Supervisor.start_link(children, options)
    :ok          = load_databases()
    :ok          = load_short_code_maps()

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


  defp load_databases() do
    path = Config.database_path

    :ok = Database.Bots.load(path)
    :ok = Database.BrowserEngines.load(path)
    :ok = Database.Clients.load(path)
    :ok = Database.Devices.load(path)
    :ok = Database.OSs.load(path)
    :ok = Database.VendorFragments.load(path)
    :ok
  end

  defp load_short_code_maps() do
    path = Config.database_path

    :ok = ShortCodeMap.DeviceBrands.load(path)
    :ok = ShortCodeMap.OSs.load(path)
    :ok
  end
end
