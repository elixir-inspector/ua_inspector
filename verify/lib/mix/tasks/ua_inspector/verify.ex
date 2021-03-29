defmodule Mix.Tasks.UaInspector.Verify do
  @moduledoc """
  Verifies UAInspector results.
  """

  @shortdoc "Verifies parser results"

  use Mix.Task

  alias Mix.UAInspector.Verify
  alias UAInspector.Downloader

  def run(args) do
    {opts, _argv, _errors} = OptionParser.parse(args, strict: [quick: :boolean])

    :ok = maybe_download(opts)
    {:ok, _} = Application.ensure_all_started(:ua_inspector)

    Verify.Fixtures.list() |> verify_all()

    Mix.shell().info("Verification complete!")
    :ok
  end

  defp compare(%{client: _} = testcase, %{client: _} = result) do
    # regular user agent
    testcase.user_agent == result.user_agent &&
      testcase.browser_family == result.browser_family &&
      testcase.os_family == result.os_family &&
      testcase.client == maybe_from_struct(result.client) &&
      testcase.device == maybe_from_struct(result.device) &&
      testcase.os == maybe_from_struct(result.os)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp compare(testcase, result) do
    # bot
    acc = testcase.user_agent == result.user_agent && testcase.bot.name == result.name

    acc =
      if Map.has_key?(testcase.bot, :category) do
        acc && testcase.bot.category == result.category
      else
        acc
      end

    acc =
      if Map.has_key?(testcase.bot, :url) do
        acc && testcase.bot.url == result.url
      else
        acc
      end

    acc =
      if Map.has_key?(testcase.bot, :producer) do
        acc && testcase.bot.producer == maybe_from_struct(result.producer)
      else
        acc
      end

    acc
  end

  defp maybe_download(quick: true), do: :ok

  defp maybe_download(_) do
    {:ok, _} = Application.ensure_all_started(:hackney)
    :ok = Downloader.download()
    :ok = Verify.Fixtures.download()

    Mix.shell().info("=== Skip downloads using '--quick' ===")

    :ok
  end

  defp maybe_from_struct(:unknown), do: :unknown
  defp maybe_from_struct(result), do: Map.from_struct(result)

  defp parse(case_data) when is_list(case_data) do
    Enum.into(case_data, %{}, fn {k, v} -> {String.to_atom(k), parse(v)} end)
  end

  defp parse(case_data), do: case_data

  defp verify(_, []), do: :ok

  defp verify(fixture, [testcase | testcases]) do
    testcase = testcase |> parse() |> Verify.Cleanup.cleanup()
    result = testcase[:user_agent] |> UAInspector.parse()

    if compare(testcase, result) do
      verify(fixture, testcases)
    else
      {
        :error,
        fixture,
        %{
          user_agent: testcase[:user_agent],
          testcase: testcase,
          result: result
        }
      }
    end
  end

  defp verify_all(fixtures) do
    fixtures
    |> Task.async_stream(&verify_fixture/1, timeout: :infinity)
    |> Enum.reject(fn {:ok, result} -> :ok == result end)
    |> case do
      [] ->
        :ok

      errors ->
        Enum.each(errors, fn
          {_, {:error, fixture, :enoent}} ->
            Mix.shell().error("Missing fixture file: #{fixture}")

          {_, {:error, fixture, error}} ->
            Mix.shell().error("-- verification failed (#{fixture}) --")
            Mix.shell().info("user_agent: #{error[:user_agent]}")
            Mix.shell().info("testcase: #{inspect(error[:testcase])}")
            Mix.shell().info("result: #{inspect(error[:result])}")
        end)

        throw("verification failed")
    end
  end

  defp verify_fixture(fixture) do
    testfile = Verify.Fixtures.download_path(fixture)

    if File.exists?(testfile) do
      [testcases] = :yamerl_constr.file(testfile, [:str_node_as_binary])

      Mix.shell().info(".. verifying: #{fixture} (#{length(testcases)} tests)")
      verify(fixture, testcases)
    else
      {:error, :enoent}
    end
  end
end
