defmodule UAInspector.Benchmark.ParseClient do
  alias UAInspector.Parser.Client

  @agent_browser "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_7; xx) AppleWebKit/530.17 (KHTML, like Gecko) Version/4.0 Safari/530.17 Skyfire/6DE"
  @agent_feed_reader "RSSOwl/2.2.1.201312301314 (Windows; U; en)"
  @agent_library "insomnia/2022.6.0"
  @agent_mediaplayer "com.devcoder.iptvxtreamplayer/111 (Linux; U; Android 12; en; Philips Google TV TA1; Build/STT2.220929.001; Cronet/114.0.5735.33)"
  @agent_mobile_app "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Mobile/15E148 Safari/605.1.15/Clipbox+/2.2.8"
  @agent_pim "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) BlueMail/0.10.31 Chrome/61.0.3163.100 Electron/2.0.18 Safari/537.36"
  @agent_unknown "match nothing"

  def run do
    Benchee.run(
      %{
        "Parse Client: browser" => fn ->
          %{type: "browser"} = Client.parse(@agent_browser, %{})
        end,
        "Parse Client: feed reader" => fn ->
          %{type: "feed reader"} = Client.parse(@agent_feed_reader, %{})
        end,
        "Parse Client: library" => fn ->
          %{type: "library"} = Client.parse(@agent_library, %{})
        end,
        "Parse Client: mediaplayer" => fn ->
          %{type: "mediaplayer"} = Client.parse(@agent_mediaplayer, %{})
        end,
        "Parse Client: mobile app" => fn ->
          %{type: "mobile app"} = Client.parse(@agent_mobile_app, %{})
        end,
        "Parse Client: pim" => fn -> %{type: "pim"} = Client.parse(@agent_pim, %{}) end,
        "Parse Client: unknown" => fn -> :unknown = Client.parse(@agent_unknown, %{}) end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}]
    )
  end
end

UAInspector.Benchmark.ParseClient.run()
