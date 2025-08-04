defmodule UAInspector.Benchmark.ParseOS do
  alias UAInspector.Parser.OS

  @agent_known "Mozilla/5.0 (PlayStation Vita 3.01) AppleWebKit/536.26 (KHTML, like Gecko) Silk/3.2"
  @agent_unknown "match nothing"

  @hints_known_agent "Mozilla/5.0 (X11; CrOS x86_64 14150.90.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.126 Safari/537.36"
  @hints_known_hints UAInspector.ClientHints.new([
                       {"sec-ch-ua-platform", "Chromium OS"},
                       {"sec-ch-ua-platform-version", "14150.90.0"},
                       {"sec-ch-ua-arch", "x86"},
                       {"sec-ch-ua-bitness", "64"}
                     ])

  def run do
    Benchee.run(
      %{
        "Parse OS: known" => fn -> %{name: _} = OS.parse(@agent_known, %{}) end,
        "Parse OS: known (client hints)" => fn ->
          %{name: _} = OS.parse(@hints_known_agent, @hints_known_hints)
        end,
        "Parse OS: unknown" => fn -> :unknown = OS.parse(@agent_unknown, %{}) end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}]
    )
  end
end

UAInspector.Benchmark.ParseOS.run()
