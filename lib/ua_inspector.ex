defmodule UAInspector do
  @moduledoc """
  User agent parser library

  ## Usage

      iex(1)> UAInspector.parse("Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
      %UAInspector.Result{
        user_agent: "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
        client: %UAInspector.Result.Client{
          engine: "WebKit",
          engine_version: "537.51.11",
          name: "Mobile Safari",
          type: "browser",
          version: "7.0"
        },
        device: %UAInspector.Result.Device{
          brand: "Apple",
          model: "iPad",
          type: "tablet"
        },
        os: %UAInspector.Result.OS{
          name: "iOS",
          platform: :unknown,
          version: "7.0.4"
        },
      }

      iex(2)> UAInspector.parse("Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36")
      %UAInspector.Result.Bot{
        user_agent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36",
        category: "Search bot",
        name: "Googlebot",
        producer: %UAInspector.Result.BotProducer{
          name: "Google Inc.",
          url: "http://www.google.com"
        },
        url: "http://www.google.com/bot.html"
      }

      iex(3)> UAInspector.parse("generic crawler agent")
      %UAInspector.Result.Bot{
        user_agent: "generic crawler agent",
        name: "Generic Bot"
      }

      iex(4)> UAInspector.parse("--- undetectable ---")
      %UAInspector.Result{
        user_agent: "--- undetectable ---",
        client: :unknown,
        device: %UAInspector.Result.Device{ type: "desktop" },
        os: :unknown
      }

  The map key `:_user_agent` will hold the unmodified passed user agent.

  If the device type cannot be determined a "desktop" device type will be
  assumed (and returned). Both `:brand` and `:model` are set to `:unknown`.

  When a bot agent is detected the result with be a `UAInspector.Result.Bot`
  struct instead of `UAInspector.Result`.
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
  Checks if UAInspector is ready to perform lookups.

  The `true == ready?` definition is made on the assumption that if there is
  at least one entry in all databases then lookups can be performed.

  Checking the state is done using the currently active databases.
  Any potentially concurrent reload requests are not considered.
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

  This process is done asynchronously in the background, so be aware that for
  some time the old data will be used for lookups.
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
