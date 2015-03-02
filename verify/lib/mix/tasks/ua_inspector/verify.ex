defmodule Mix.Tasks.Ua_inspector.Verify do
  use Mix.Task

  alias Mix.Tasks.Ua_inspector.Verify

  def run(_args) do
    { :ok, _ } = Application.ensure_all_started(:ua_inspector)
    :ok        = Verify.Fixtures.download()

    Verify.Fixtures.list() |> verify_all()

    Mix.shell.info "Verification complete!"
    :ok
  end


  defp compare(testcase, result) do
    testcase.user_agent == result.user_agent
    && testcase.device  == Map.from_struct(result.device)
    && testcase.os == Map.from_struct(result.os)
  end

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
      false -> throw "verification failed: #{ testcase[:user_agent] }"
      true  -> verify(testcases)
    end
  end

  defp verify_all([]),                          do: :ok
  defp verify_all([{ fixture, _ } | fixtures ]) do
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
