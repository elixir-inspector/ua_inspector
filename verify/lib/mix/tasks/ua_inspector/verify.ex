defmodule Mix.Tasks.UAInspector.Verify do
  use Mix.Task

  alias Mix.Tasks.UAInspector.Verify

  def run(_args) do
    { :ok, _ } = Application.ensure_all_started(:ua_inspector)
    :ok        = Verify.Fixtures.download()

    Verify.Fixtures.list() |> verify_all()

    Mix.shell.info "Verification complete!"
    :ok
  end


  defp compare(testcase, result) do
    testcase.user_agent == result.user_agent
    && testcase.client == maybe_from_struct(result.client)
    && testcase.device == maybe_from_struct(result.device)
    && testcase.os == maybe_from_struct(result.os)
   end

  defp maybe_from_struct(:unknown), do: :unknown
  defp maybe_from_struct(result),   do: Map.from_struct(result)

  defp parse(case_data) when is_list(case_data) do
    case_data
    |> Enum.map(fn ({ k, v }) -> { String.to_atom(k), parse(v) } end)
    |> Enum.into(%{})
  end
  defp parse(case_data), do: case_data

  defp unravel_list([[ _ ] = cases ]), do: cases
  defp unravel_list([ cases ]),        do: cases

  defp verify([]),                      do: nil
  defp verify([ testcase | testcases ]) do
    testcase = testcase |> parse() |> Verify.Cleanup.cleanup()
    result   = testcase[:user_agent] |> UAInspector.parse()

    case compare(testcase, result) do
      true  -> verify(testcases)
      false ->
        IO.puts "-- verification failed --"
        IO.puts "user_agent: #{ testcase[:user_agent] }"
        IO.puts "testcase: #{ inspect testcase }"
        IO.puts "result: #{ inspect result }"

        throw "verification failed"
    end
  end

  defp verify_all([]),                    do: :ok
  defp verify_all([ fixture | fixtures ]) do
    Mix.shell.info ".. verifying: #{ fixture }"

    testcases =
         fixture
      |> Verify.Fixtures.download_path()
      |> :yamerl_constr.file([ :str_node_as_binary ])
      |> unravel_list()

    verify(testcases)
    verify_all(fixtures)
  end
end

#
# Elixir 1.0.2 requires the underscore module naming.
# https://github.com/elixytics/ua_inspector/pull/1
#
defmodule Mix.Tasks.Ua_inspector.Verify do
  defdelegate run(args), to: Mix.Tasks.UAInspector.Verify
end
