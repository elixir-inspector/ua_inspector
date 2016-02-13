defmodule Mix.UAInspector.Verify do
  @moduledoc """
  Verifies UAInspector results.
  """

  alias Mix.UAInspector.Verify


  @behaviour Mix.Task

  def run(args) do
    { opts, _argv, _errors } = OptionParser.parse(args)

    :ok        = maybe_download(opts)
    { :ok, _ } = Application.ensure_all_started(:ua_inspector)

    Verify.Fixtures.list() |> verify_all()

    Mix.shell.info "Verification complete!"
    :ok
  end


  defp compare(testcase, result) do
    if Map.has_key?(testcase, :client) && Map.has_key?(result, :client) do
      # regular user agent
      testcase.user_agent == result.user_agent
      && testcase.client == maybe_from_struct(result.client)
      && testcase.device == maybe_from_struct(result.device)
      && testcase.os == maybe_from_struct(result.os)
    else
      # bot
      acc =
        testcase.user_agent == result.user_agent
        && testcase.bot.name == result.name

      if acc && Map.has_key?(testcase.bot, :category) do
        acc = acc && testcase.bot.category == result.category
      end

      if acc && Map.has_key?(testcase.bot, :url) do
        acc = acc && testcase.bot.url == result.url
      end

      if acc && Map.has_key?(testcase.bot, :producer) do
        acc = acc && testcase.bot.producer == maybe_from_struct(result.producer)
      end

      acc
    end
  end

  defp maybe_download([ quick: true ]), do: :ok
  defp maybe_download(_)                do
    :ok = Mix.UAInspector.Download.Databases.run(["--force"])
    :ok = Mix.UAInspector.Download.ShortCodeMaps.run(["--force"])
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
