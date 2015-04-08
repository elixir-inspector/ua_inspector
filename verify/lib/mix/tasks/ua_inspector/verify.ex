defmodule Mix.Tasks.UAInspector.Verify do
  @moduledoc """
  Verifies UAInspector results.
  """

  alias Mix.Tasks.UAInspector.Verify

  def run(args) do
    { opts, _argv, _errors } = OptionParser.parse(args)

    :ok        = maybe_download(opts)
    { :ok, _ } = Application.ensure_all_started(:ua_inspector)

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

  defp maybe_download([ quick: true ]), do: :ok
  defp maybe_download(_)                do
    :ok = Mix.Tasks.UAInspector.Databases.Download.run(["--force"])
    :ok = Verify.Fixtures.download()

    Mix.shell.info "=== Skip downloads using '--quick' ==="

    :ok
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
    testfile = fixture |> Verify.Fixtures.download_path()

    case File.exists?(testfile) do
      false ->
        Mix.shell.error "Fixture file #{ fixture } missing."
        Mix.shell.error "Please run without '--quick' param to download it!"

      true ->
        testcases =
             testfile
          |> :yamerl_constr.file([ :str_node_as_binary ])
          |> unravel_list()

        Mix.shell.info ".. verifying: #{ fixture } (#{ length(testcases) } tests)"
        verify(testcases)
    end

    verify_all(fixtures)
  end
end

if Version.match?(System.version, ">= 1.0.3") do
  #
  # Elixir 1.0.3 and up requires mixed case module namings.
  # The "double uppercase letter" of "UAInspector" violates
  # this rule. This fake task acts as a workaround.
  #
  defmodule Mix.Tasks.UaInspector.Verify do
    @moduledoc false
    @shortdoc  "Verifies parser results"

    use Mix.Task

    defdelegate run(args), to: Mix.Tasks.UAInspector.Verify
  end
else
  #
  # Elixir 1.0.2 requires the underscore module naming.
  # https://github.com/elixytics/ua_inspector/pull/1
  #
  defmodule Mix.Tasks.Ua_inspector.Verify do
    @moduledoc false
    @shortdoc  "Verifies parser results"

    use Mix.Task

    defdelegate run(args), to: Mix.Tasks.UAInspector.Verify
  end
end
