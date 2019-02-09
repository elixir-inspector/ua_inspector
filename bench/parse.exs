defmodule UAInspector.Benchmark.Parse do
  @agent_bot "Mozilla/5.0 (compatible; special_archiver/3.2.0 +http://www.loc.gov/webarchiving/notice_to_webmasters.html)"
  @agent_desktop "Mozilla/5.0 (AmigaOS; U; AmigaOS 1.3; en-US; rv:1.8.1.21) Gecko/20090303 SeaMonkey/1.1.15"
  @agent_smartphone "Mozilla/5.0 (Linux; Android 6.0; U007 Pro Build/MRA58K; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/44.0.2403.119 Mobile Safari/537.36"
  @agent_tablet "Mozilla/5.0 (Linux; U; Android 4.2.2; it-it; Surfing TAB B 9.7 3G Build/JDQ39) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
  @agent_unknown "Mozilla/5.0 (Linux; U; Android 4.0.4; en-us; NABI2-NV7A Build/IMM76L)Maxthon AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30"

  def run do
    Benchee.run(
      %{
        "Parse: bot" => fn -> UAInspector.parse(@agent_bot) end,
        "Parse: desktop" => fn -> UAInspector.parse(@agent_desktop) end,
        "Parse: smartphone" => fn -> UAInspector.parse(@agent_smartphone) end,
        "Parse: tablet" => fn -> UAInspector.parse(@agent_tablet) end,
        "Parse: unknown" => fn -> UAInspector.parse(@agent_unknown) end
      },
      formatter_options: %{console: %{comparison: false}},
      warmup: 2,
      time: 10
    )
  end
end

UAInspector.Benchmark.Parse.run()
