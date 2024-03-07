defmodule UAInspector.Benchmark.ParseList do
  @sample_data File.read!("bench/data/user-agents-51d-1000.txt") |> String.split("\n")

  @inputs %{
    "1" => Enum.take_random(@sample_data, 1),
    "10" => Enum.take_random(@sample_data, 10),
    "100" => Enum.take_random(@sample_data, 100),
    "1_000" => Enum.take_random(@sample_data, 1000)
  }

  def run do
    Benchee.run(
      %{
        "UAInspector.parse/1" => fn list -> Enum.each(list, &UAInspector.parse(&1)) end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}],
      inputs: @inputs,
      warmup: 2,
      time: 60
    )
  end
end

UAInspector.Benchmark.ParseList.run()
