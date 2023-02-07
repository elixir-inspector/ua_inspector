defmodule UAInspector do
  @moduledoc """
  User agent parser library.

  ## Preparation

  1. Verify your supervision setup according to `UAInspector.Supervisor`
  2. Revise the default configuration values of `UAInspector.Config` and
     adjust to your project/environment where necessary
  3. Download a copy of the database files as outlined in
     `UAInspector.Downloader`

  Please re-download (or otherwise update your copy of) the database
  if the default `:remote_release` in `UAInspector.Config` changes.

  ## Usage

  The map key `:user_agent` will hold the unmodified passed user agent.

  If the device type cannot be determined a "desktop" device type will be
  assumed (and returned). Both `:brand` and `:model` are set to `:unknown`.

  When a bot agent is detected the result with be a `UAInspector.Result.Bot`
  struct instead of `UAInspector.Result`.

  ### Basic User Agent Lookup

      iex> UAInspector.parse("Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
      %UAInspector.Result{
        browser_family: "Safari",
        client: %UAInspector.Result.Client{
          engine: "WebKit",
          engine_version: "537.51.1",
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

  ### Lookup with Additional Client Hints

      iex> client_hints = UAInspector.ClientHints.new([
      ...>   {"sec-ch-ua", ~S(" Not A;Brand";v="99", "Chromium";v="95", "Microsoft Edge";v="95")},
      ...>   {"sec-ch-ua-mobile", "?0"},
      ...>   {"sec-ch-ua-platform", "Windows"},
      ...>   {"sec-ch-ua-platform-version", "14.0.0"}
      ...> ])
      iex> UAInspector.parse("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36 Edg/95.0.1020.44", client_hints)
      %UAInspector.Result{
        browser_family: "Internet Explorer",
        client: %UAInspector.Result.Client{
          engine: "Blink",
          engine_version: "95.0.4638.69",
          name: "Microsoft Edge",
          type: "browser",
          version: "95.0.1020.44"
        },
        device: %UAInspector.Result.Device{
          brand: :unknown,
          model: :unknown,
          type: "desktop"
        },
        os: %UAInspector.Result.OS{
          name: "Windows",
          platform: "x64",
          version: "10"
        },
        os_family: "Windows",
        user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36 Edg/95.0.1020.44"
      }

      iex> client_hints = UAInspector.ClientHints.new([{"x-requested-with", "org.telegram.messenger"}])
      iex> UAInspector.parse("Mozilla/5.0 (Linux; Android 11; Pixel 3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Mobile Safari/537.36", client_hints)
      %UAInspector.Result{
        browser_family: :unknown,
        client: %UAInspector.Result.Client{
          engine: :unknown,
          engine_version: :unknown,
          name: "Telegram",
          type: "mobile app",
          version: :unknown
        },
        device: %UAInspector.Result.Device{
          brand: "Google",
          model: "Pixel 3",
          type: "smartphone"
        },
        os: %UAInspector.Result.OS{
          name: "Android",
          platform: :unknown,
          version: "11"
        },
        os_family: "Android",
        user_agent: "Mozilla/5.0 (Linux; Android 11; Pixel 3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Mobile Safari/537.36"
      }

  ### Bot Result

      iex> UAInspector.parse("Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36")
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

      iex> UAInspector.parse("generic crawler agent")
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

  ### Unknown User Agent

      iex> UAInspector.parse("--- undetectable ---")
      %UAInspector.Result{
        browser_family: :unknown,
        client: :unknown,
        device: :unknown,
        os: :unknown,
        os_family: :unknown,
        user_agent: "--- undetectable ---"
      }
  """

  alias UAInspector.ClientHints
  alias UAInspector.Database
  alias UAInspector.Parser
  alias UAInspector.Result
  alias UAInspector.Result.Bot
  alias UAInspector.ShortCodeMap

  @storage_modules [
    ClientHints.Apps,
    ClientHints.Browsers,
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
    ShortCodeMap.ClientHintBrowserMapping,
    ShortCodeMap.ClientHintOSMapping,
    ShortCodeMap.DesktopFamilies,
    ShortCodeMap.MobileBrowsers,
    ShortCodeMap.OSFamilies,
    ShortCodeMap.OSs
  ]

  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(Result.t() | Bot.t() | String.t() | nil, ClientHints.t() | nil) :: boolean
  def bot?(ua, client_hints \\ nil)

  def bot?(nil, nil), do: false
  def bot?("", nil), do: false
  def bot?(nil, client_hints), do: Parser.bot?("", client_hints)
  def bot?(ua, client_hints), do: Parser.bot?(ua, client_hints)

  @doc """
  Checks if a user agent is a desktop device.
  """
  @spec desktop?(Result.t() | Bot.t() | String.t() | nil, ClientHints.t() | nil) :: boolean
  def desktop?(ua, client_hints \\ nil)

  def desktop?(nil, nil), do: false
  def desktop?("", nil), do: false
  def desktop?(nil, client_hints), do: Parser.desktop?("", client_hints)
  def desktop?(ua, client_hints), do: Parser.desktop?(ua, client_hints)

  @doc """
  Checks if a user agent is a HbbTV and returns its version if so.
  """
  @spec hbbtv?(Result.t() | Bot.t() | String.t() | nil, ClientHints.t() | nil) ::
          false | String.t()
  def hbbtv?(ua, client_hints \\ nil)

  def hbbtv?(nil, nil), do: false
  def hbbtv?("", nil), do: false
  def hbbtv?(nil, client_hints), do: Parser.hbbtv?("", client_hints)
  def hbbtv?(ua, client_hints), do: Parser.hbbtv?(ua, client_hints)

  @doc """
  Checks if a user agent is a mobile device.
  """
  @spec mobile?(Result.t() | Bot.t() | String.t() | nil, ClientHints.t() | nil) :: boolean
  def mobile?(ua, client_hints \\ nil)

  def mobile?(nil, nil), do: false
  def mobile?("", nil), do: false
  def mobile?(nil, client_hints), do: Parser.mobile?("", client_hints)
  def mobile?(ua, client_hints), do: Parser.mobile?(ua, client_hints)

  @doc """
  Checks if a user agent is a ShellTV.
  """
  @spec shelltv?(Result.t() | Bot.t() | String.t() | nil, ClientHints.t() | nil) :: boolean
  def shelltv?(ua, client_hints \\ nil)

  def shelltv?(nil, nil), do: false
  def shelltv?("", nil), do: false
  def shelltv?(nil, client_hints), do: Parser.shelltv?("", client_hints)
  def shelltv?(ua, client_hints), do: Parser.shelltv?(ua, client_hints)

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t() | nil, ClientHints.t() | nil) :: Result.t() | Bot.t()
  def parse(ua, client_hints \\ nil)

  def parse(nil, nil), do: %Result{user_agent: nil}
  def parse("", nil), do: %Result{user_agent: ""}
  def parse(nil, client_hints), do: Parser.parse("", client_hints)
  def parse(ua, client_hints), do: Parser.parse(ua, client_hints)

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t() | nil, ClientHints.t() | nil) :: Result.t()
  def parse_client(ua, client_hints \\ nil)

  def parse_client(nil, nil), do: %Result{user_agent: nil}
  def parse_client("", nil), do: %Result{user_agent: ""}
  def parse_client(nil, client_hints), do: Parser.parse_client("", client_hints)
  def parse_client(ua, client_hints), do: Parser.parse_client(ua, client_hints)

  @doc """
  Checks if UAInspector is ready to perform lookups.

  The `true == ready?` definition is made on the assumption that if there is
  at least one entry in all databases then lookups can be performed.

  Checking the state is done using the currently active databases.
  Any potentially concurrent reload requests are not considered.
  """
  @spec ready?() :: boolean
  def ready? do
    Enum.all?(@storage_modules, fn storage_module ->
      contents = storage_module.list()

      [] != contents && %{} != contents
    end)
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
