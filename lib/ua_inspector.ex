defmodule UAInspector do
  @moduledoc """
  UAInspector - User agent parser library
  """

  alias UAInspector.Database
  alias UAInspector.Parser
  alias UAInspector.Result
  alias UAInspector.Result.Bot
  alias UAInspector.ShortCodeMap

  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(String.t() | nil) :: boolean
  def bot?(nil), do: false
  def bot?(""), do: false
  def bot?(ua), do: Parser.bot?(ua)

  @doc """
  Checks if a user agent is a HbbTV and returns its version if so.
  """
  @spec hbbtv?(String.t() | nil) :: false | String.t()
  def hbbtv?(nil), do: false
  def hbbtv?(""), do: false
  def hbbtv?(ua), do: Parser.hbbtv?(ua)

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t() | nil) :: Result.t() | Bot.t()
  def parse(nil), do: %Result{user_agent: nil}
  def parse(""), do: %Result{user_agent: ""}
  def parse(ua), do: Parser.parse(ua)

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t() | nil) :: Result.t()
  def parse_client(nil), do: %Result{user_agent: nil}
  def parse_client(""), do: %Result{user_agent: ""}
  def parse_client(ua), do: Parser.parse_client(ua)

  @doc """
  Checks if there is data to use in lookups.

  The check is done against all currently available internal data tables.

  An empty database is any of the lookup modules considered to be "not ready".
  """
  @spec ready?() :: boolean
  def ready? do
    [
      Database.Bots,
      Database.BrowserEngines,
      Database.Clients,
      Database.DevicesHbbTV,
      Database.DevicesRegular,
      Database.OSs,
      Database.VendorFragments,
      ShortCodeMap.ClientBrowsers,
      ShortCodeMap.DesktopFamilies,
      ShortCodeMap.DeviceBrands,
      ShortCodeMap.MobileBrowsers,
      ShortCodeMap.OSFamilies,
      ShortCodeMap.OSs
    ]
    |> Enum.all?(fn database -> [] != database.list() end)
  end

  @doc """
  Reloads all databases.
  """
  @spec reload() :: :ok
  def reload do
    [
      Database.Bots,
      Database.BrowserEngines,
      Database.Clients,
      Database.DevicesHbbTV,
      Database.DevicesRegular,
      Database.OSs,
      Database.VendorFragments,
      ShortCodeMap.ClientBrowsers,
      ShortCodeMap.DesktopFamilies,
      ShortCodeMap.DeviceBrands,
      ShortCodeMap.MobileBrowsers,
      ShortCodeMap.OSFamilies,
      ShortCodeMap.OSs
    ]
    |> Enum.each(fn database -> GenServer.cast(database, :reload) end)
  end
end
