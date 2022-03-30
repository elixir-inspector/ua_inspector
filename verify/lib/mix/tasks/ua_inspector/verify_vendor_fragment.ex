defmodule Mix.Tasks.UaInspector.VerifyVendorFragment do
  @moduledoc """
  Verifies UAInspector VendorFragment parser results.
  """

  @shortdoc "Verifies VendorFragment parser results"

  use Mix.Task

  alias UAInspector.Config
  alias UAInspector.Downloader
  alias UAInspector.Parser.VendorFragment
  alias UAInspectorVerify.FixturesVendorFragment

  def run(args) do
    {opts, _argv, _errors} =
      OptionParser.parse(args, strict: [remote_release: :string, quick: :boolean])

    opts = Map.new(opts)

    :ok = setup_remote_release(opts)
    :ok = maybe_download(opts)
    {:ok, _} = Application.ensure_all_started(:ua_inspector)

    Mix.shell().info(["Verification remote release: ", Config.remote_release()])
    FixturesVendorFragment.list() |> verify_all()
    Mix.shell().info("Verification complete!")
    :ok
  end

  defp compare(%{vendor: testcase}, result) do
    testcase == result
  end

  defp maybe_download(%{quick: true}), do: :ok

  defp maybe_download(_) do
    {:ok, _} = Application.ensure_all_started(:hackney)
    :ok = Downloader.download()
    :ok = FixturesVendorFragment.download()

    Mix.shell().info("=== Skip downloads using '--quick' ===")

    :ok
  end

  defp parse(case_data) when is_list(case_data) do
    Enum.into(case_data, %{}, fn {k, v} -> {String.to_atom(k), parse(v)} end)
  end

  defp parse(case_data), do: case_data

  defp setup_remote_release(%{remote_release: remote_release}) when is_binary(remote_release),
    do: Application.put_env(:ua_inspector, :remote_release, remote_release)

  defp setup_remote_release(_), do: :ok

  defp verify(_, []), do: :ok

  defp verify(fixture, [testcase | testcases]) do
    testcase = testcase |> parse()
    result = testcase[:useragent] |> VendorFragment.parse()

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
    testfile = FixturesVendorFragment.download_path(fixture)

    if File.exists?(testfile) do
      [testcases] = :yamerl_constr.file(testfile, [:str_node_as_binary])

      Mix.shell().info(".. verifying: #{fixture} (#{length(testcases)} tests)")
      verify(fixture, testcases)
    else
      {:error, fixture, :enoent}
    end
  end
end
