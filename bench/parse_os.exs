defmodule UAInspector.Benchmark.ParseOS do
  alias UAInspector.Parser.OS

  @agent_desktop "Mozilla/5.0 (AmigaOS; U; AmigaOS 1.3; en-US; rv:1.8.1.21) Gecko/20090303 SeaMonkey/1.1.15"
  @agent_smartphone "Mozilla/5.0 (Linux; Android 6.0; U007 Pro Build/MRA58K; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/44.0.2403.119 Mobile Safari/537.36"
  @agent_tablet "Mozilla/5.0 (Linux; U; Android 4.2.2; it-it; Surfing TAB B 9.7 3G Build/JDQ39) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
  @agent_unknown "Mozilla/5.0 (Linux; U; Android 4.0.4; en-us; NABI2-NV7A Build/IMM76L)Maxthon AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30"

  def run do
    Benchee.run(
      %{
        "Parse OS: desktop" => fn -> OS.parse(@agent_desktop) end,
        "Parse OS: smartphone" => fn -> OS.parse(@agent_smartphone) end,
        "Parse OS: tablet" => fn -> OS.parse(@agent_tablet) end,
        "Parse OS: unknown" => fn -> OS.parse(@agent_unknown) end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}],
      warmup: 2,
      time: 10
    )
  end
end

UAInspector.Benchmark.ParseOS.run()
