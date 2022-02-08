defmodule UAInspector do
  @moduledoc """
  User agent parser library.

  ## Preparation

  1. Verify your supervision setup according to `UAInspector.Supervisor`
  2. Revise the default configuration values of `UAInspector.Config` and
     adjust to your project/environment where necessary
  3. Download a copy of the database files as outlined in
     `UAInspector.Downloader`

  ## Usage

      iex(1)> UAInspector.parse("Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
      %UAInspector.Result{
        browser_family: "Safari",
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
        os_family: "iOS",
        user_agent: "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
      }

      iex(2)> UAInspector.parse("Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36")
      %UAInspector.Result.Bot{
        category: "Search bot",
        name: "Googlebot",
        producer: %UAInspector.Result.BotProducer{
          name: "Google Inc.",
          url: "http://www.google.com"
        },
        url: "http://www.google.com/bot.html",
        user_agent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36"
      }

      iex(3)> UAInspector.parse("generic crawler agent")
      %UAInspector.Result.Bot{
        category: :unknown,
        name: "Generic Bot",
        producer: %UAInspector.Result.BotProducer{
          name: :unknown,
          url: :unknown
        },
        url: :unknown,
        user_agent: "generic crawler agent"
      }

      iex(4)> UAInspector.parse("--- undetectable ---")
      %UAInspector.Result{
        browser_family: :unknown,
        client: :unknown,
        device: :unknown,
        os: :unknown,
        os_family: :unknown,
        user_agent: "--- undetectable ---"
      }

  The map key `:user_agent` will hold the unmodified passed user agent.

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

  @storage_modules [
    Database.Bots,
    Database.BrowserEngines,
    Database.Clients,
    Database.DevicesHbbTV,
    Database.DevicesNotebooks,
    Database.DevicesRegular,
    Database.DevicesShellTV,
    Database.OSs,
    Database.VendorFragments,
    ShortCodeMap.BrowserFamilies,
    ShortCodeMap.ClientBrowsers,
    ShortCodeMap.DesktopFamilies,
    ShortCodeMap.MobileBrowsers,
    ShortCodeMap.OSFamilies,
    ShortCodeMap.OSs
  ]

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
  Checks if a user agent is a ShellTV.
  """
  @spec shelltv?(String.t() | nil) :: boolean
  def shelltv?(nil), do: false
  def shelltv?(""), do: false
  def shelltv?(ua), do: Parser.shelltv?(ua)

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
    Enum.all?(@storage_modules, &([] != &1.list()))
  end

  @doc """
  Reloads all databases.

  You can pass `[async: true|false]` to define if the reload should happen
  in the background (default!) or block your calling process until completed.
  """
  @spec reload(Keyword.t()) :: :ok
  def reload(opts \\ [async: true]) do
    if opts[:async] do
      Enum.each(@storage_modules, &GenServer.cast(&1, :reload))
    else
      @storage_modules
      |> Task.async_stream(&GenServer.call(&1, :reload), ordered: false)
      |> Stream.run()
    end
  end
end
