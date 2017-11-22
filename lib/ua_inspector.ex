defmodule UAInspector do
  @moduledoc """
  UA Inspector - User agent parser library
  """

  alias UAInspector.Database
  alias UAInspector.Pool
  alias UAInspector.ShortCodeMap

  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(String.t()) :: boolean
  defdelegate bot?(ua), to: Pool

  @doc """
  Checks if a user agent is a HbbTV and returns its version if so.
  """
  @spec hbbtv?(String.t()) :: false | String.t()
  defdelegate hbbtv?(ua), to: Pool

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t()) :: map
  defdelegate parse(ua), to: Pool

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t()) :: map
  defdelegate parse_client(ua), to: Pool

  @doc """
  Reloads all databases.
  """
  @spec reload() :: :ok
  def reload() do
    [
      Database.Bots,
      Database.BrowserEngines,
      Database.Clients,
      Database.Devices,
      Database.OSs,
      Database.VendorFragments,
      ShortCodeMap.ClientBrowsers,
      ShortCodeMap.DeviceBrands,
      ShortCodeMap.MobileBrowsers,
      ShortCodeMap.OSs
    ]
    |> Enum.each(fn database -> GenServer.cast(database, :reload) end)
  end
end
