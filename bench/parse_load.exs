agentstream =
  [__DIR__, "agents.txt"]
  |> Path.join()
  |> File.read!()
  |> Code.eval_string([], file: "agents.txt")
  |> case do
    {agentlist, _} when is_list(agentlist) -> agentlist
    _ -> []
  end
  |> Stream.cycle()

Enum.each([2, 4, 8, 16, 32], fn parallel ->
  IO.puts("Starting parallel: #{parallel}")

  for _ <- 1..parallel do
    Task.async(fn ->
      agentstream
      |> Enum.take(1000)
      |> Enum.each(&UAInspector.parse/1)
    end)
  end
  |> Enum.map(&Task.await(&1, :infinity))

  IO.puts("done")
end)
