defmodule UAInspector.Benchmark.Parse do
  @agent_bot "Mozilla/5.0 (compatible; special_archiver/3.2.0 +http://www.loc.gov/webarchiving/notice_to_webmasters.html)"
  @agent_desktop "Mozilla/5.0 (AmigaOS; U; AmigaOS 1.3; en-US; rv:1.8.1.21) Gecko/20090303 SeaMonkey/1.1.15"
  @agent_hbbtv "Opera/9.80 (Linux mips ; U; HbbTV/1.1.1 (; Philips; ; ; ; ) CE-HTML/1.0 NETTV/3.2.1; en) Presto/2.6.33 Version/10.70"
  @agent_smartphone "Mozilla/5.0 (Linux; Android 6.0; U007 Pro Build/MRA58K; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/44.0.2403.119 Mobile Safari/537.36"
  @agent_tablet "Mozilla/5.0 (Linux; U; Android 4.2.2; it-it; Surfing TAB B 9.7 3G Build/JDQ39) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
  @agent_unknown "match nothing"

  @hints_desktop_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36 Edg/95.0.1020.44"
  @hints_desktop_hints UAInspector.ClientHints.new([
                         {"sec-ch-ua",
                          ~S(" Not A;Brand";v="99", "Chromium";v="95", "Microsoft Edge";v="95")},
                         {"sec-ch-ua-mobile", "?0"},
                         {"sec-ch-ua-platform", "Windows"},
                         {"sec-ch-ua-platform-version", "14.0.0"}
                       ])

  @hints_smartphone_agent "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36"
  @hints_smartphone_hints UAInspector.ClientHints.new([
                            {"sec-ch-ua",
                             ~S("Google Chrome";v="123.0.6312.99", "Not:A-Brand";v="8.0.0.0", "Chromium";v="123.0.6312.99")},
                            {"sec-ch-ua-full-version", "123.0.6312.99"},
                            {"sec-ch-ua-model", "WP2"},
                            {"sec-ch-ua-mobile", "?1"},
                            {"sec-ch-ua-platform", "Android"},
                            {"sec-ch-ua-platform-version", "8.0.0"}
                          ])

  def run do
    Benchee.run(
      %{
        "Parse: bot" => fn -> %UAInspector.Result.Bot{} = UAInspector.parse(@agent_bot) end,
        "Parse: desktop" => fn ->
          %{device: %{type: "desktop"}} = UAInspector.parse(@agent_desktop)
        end,
        "Parse: desktop (client hints)" => fn ->
          %{device: %{type: "desktop"}} =
            UAInspector.parse(@hints_desktop_agent, @hints_desktop_hints)
        end,
        "Parse: hbbtv" => fn -> %{device: %{type: "tv"}} = UAInspector.parse(@agent_hbbtv) end,
        "Parse: smartphone" => fn ->
          %{device: %{type: "smartphone"}} = UAInspector.parse(@agent_smartphone)
        end,
        "Parse: smartphone (client hints)" => fn ->
          %{device: %{type: "smartphone"}} =
            UAInspector.parse(@hints_smartphone_agent, @hints_smartphone_hints)
        end,
        "Parse: tablet" => fn ->
          %{device: %{type: "tablet"}} = UAInspector.parse(@agent_tablet)
        end,
        "Parse: unknown" => fn -> %{device: :unknown} = UAInspector.parse(@agent_unknown) end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}]
    )
  end
end

UAInspector.Benchmark.Parse.run()
