defmodule UAInspectorVerify.Verify.Client do
  @moduledoc false

  @browser_mobile_app [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Colibri/1.16.0 Chrome/78.0.3904.99 Electron/7.1.1 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Polypane/2.1.2 Chrome/78.0.3904.130 Electron/7.1.12 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Sizzy/0.0.21 Chrome/73.0.3683.121 Electron/5.0.2 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) TweakStyle/0.9.2 Chrome/49.0.2623.75 Electron/0.37.5 Safari/537.36 (Tab 1)",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) VibeMate/1.9.2 Chrome/104.0.5112.81 Electron/20.0.1 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) LTBrowser/1.5.1 Chrome/80.0.3987.163 Electron/8.5.5 Safari/537.36"
  ]

  @pim_mobile_app [
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Franz/5.4.1 Chrome/76.0.3809.146 Electron/6.0.10 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) BlueMail/0.10.31 Chrome/61.0.3163.100 Electron/2.0.18 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Evernote/10.8.5 Chrome/87.0.4280.88 Electron/11.1.1 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Notion/2.0.8 Chrome/76.0.3809.146 Electron/6.1.5 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) ramboxpro/1.5.2 Chrome/83.0.4103.122 Electron/9.4.4 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) ramboxpro/1.5.2 Chrome/83.0.4103.122 Electron/9.4.4 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Mailspring/1.7.4 Chrome/69.0.3497.128 Electron/4.2.2 Safari/537.36"
  ]

  def verify(
        %{
          user_agent:
            "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 10.0; Win64; x64; Anonymisiert durch AlMiSoft Browser-Maulkorb 39663422; Trident/7.0; .NET4.0C; .NET4.0E; .NET CLR 2.0.50727; .NET CLR 3.0.30729; .NET CLR 3.5.30729; Tablet PC 2.0; Browzar)"
        },
        _result
      ) do
    # requires mobile app parsing to be skipped
    # fixture is pure browser parser result
    true
  end

  def verify(
        %{user_agent: "Mozilla/5.0 (X11; Linux x86_64; rv:21.0) Gecko/20100101 SlimerJS/0.7"},
        _result
      ) do
    # requires library only client parsing
    true
  end

  def verify(
        %{
          client: %{name: "Beaker Browser", type: "browser"} = testcase,
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) BeakerBrowser/0.8.2 Chrome/66.0.3359.181 Electron/3.0.9 Safari/537.36"
        },
        %{name: "BeakerBrowser", type: "mobile app"} = result
      ) do
    # requires browser only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "Catalyst", type: "browser"} = testcase,
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) catalyst/3.5.3 Chrome/116.0.5845.190 Electron/26.2.4 Safari/537.36"
        },
        %{name: "catalyst", type: "mobile app"} = result
      ) do
    # requires browser only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "Flash Browser", type: "browser"} = testcase,
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) FlashBrowser/1.0.0 Chrome/83.0.4103.122 Electron/9.1.0 Safari/537.36"
        },
        %{name: "FlashBrowser", type: "mobile app"} = result
      ) do
    # requires browser only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "Glass Browser", type: "browser"} = testcase,
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) GlassBrowser/0.5.0 Chrome/56.0.2924.87 Electron/1.6.15 Safari/537.36"
        },
        %{name: "GlassBrowser", type: "mobile app"} = result
      ) do
    # requires browser only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "LT Browser", type: "browser"} = testcase,
          user_agent:
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) LTBrowser/1.5.1 Chrome/80.0.3987.163 Electron/8.5.5 Safari/537.36"
        },
        %{name: "LTBrowser", type: "mobile app"} = result
      ) do
    # requires browser only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "Peeps dBrowser", type: "browser"} = testcase,
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) dBrowser/1.0.0 Chrome/84.0.4129.0 Electron/10.0.0-beta.2 Safari/537.36"
        },
        %{name: "dBrowser", type: "mobile app"} = result
      ) do
    # requires browser only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "Sushi Browser", type: "browser"} = testcase,
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) SushiBrowser/0.32.0 Chrome/85.0.4183.121 Electron/10.1.3 Safari/537.36"
        },
        %{name: "SushiBrowser", type: "mobile app"} = result
      ) do
    # requires browser only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "OhHai Browser", type: "browser"} = testcase,
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) OhHaiBrowser/3.3.0 Chrome/69.0.3497.106 Electron/4.0.4 Safari/537.36"
        },
        %{name: "OhHaiBrowser", type: "mobile app"} = result
      ) do
    # requires browser only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{client: %{type: "browser"} = testcase, user_agent: user_agent},
        %{type: "mobile app"} = result
      )
      when user_agent in @browser_mobile_app do
    # requires browser only client parsing for full result check
    testcase.name == result.name &&
      testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "Basecamp", type: "pim"} = testcase,
          user_agent:
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Basecamp3/2.1.0 Chrome/78.0.3904.130 Electron/7.1.5 Safari/537.36"
        },
        %{name: "Basecamp3", type: "mobile app"} = result
      ) do
    # requires pim only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{
          client: %{name: "Rambox Pro", type: "pim"} = testcase,
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) ramboxpro/1.5.2 Chrome/83.0.4103.122 Electron/9.4.4 Safari/537.36"
        },
        %{name: "ramboxpro", type: "mobile app"} = result
      ) do
    # requires pim only client parsing for full result check
    testcase.version == result.version
  end

  def verify(
        %{client: %{type: "pim"} = testcase, user_agent: user_agent},
        %{type: "mobile app"} = result
      )
      when user_agent in @pim_mobile_app do
    # requires pim only client parsing for full result check
    testcase.name == result.name &&
      testcase.version == result.version
  end

  def verify(%{client: %{engine: _} = testcase}, result) do
    testcase.name == result.name &&
      testcase.type == result.type &&
      testcase.version == result.version &&
      testcase.engine == result.engine &&
      testcase.engine_version == result.engine_version
  end

  def verify(%{client: testcase}, result) do
    testcase.name == result.name &&
      testcase.type == result.type &&
      testcase.version == result.version
  end
end
