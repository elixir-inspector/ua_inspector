defmodule UAInspector.Benchmark.Parse do
  def run() do
    [__DIR__, "agents.txt"]
    |> Path.join()
    |> File.read!()
    |> Code.eval_string([], file: "agents.txt")
    |> case do
      {agentlist, _} when is_list(agentlist) -> agentlist
      _ -> []
    end
    |> Stream.cycle()
    |> run_benchmark()
  end

  defp run_benchmark(agentstream) do
    Enum.each([2, 4, 8, 16, 32], fn parallel ->
      IO.puts("Starting parallel: #{parallel}")

      {us, _} =
        :timer.tc(fn ->
          for _ <- 1..parallel do
            Task.async(fn ->
              agentstream
              |> Enum.take(1000)
              |> Enum.each(&UAInspector.parse/1)
            end)
          end
          |> Enum.map(&Task.await(&1, :infinity))
        end)

      IO.puts("done in #{us} microseconds")
    end)
  end
end

UAInspector.Benchmark.Parse.run()
