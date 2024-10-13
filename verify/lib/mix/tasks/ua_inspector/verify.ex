defmodule Mix.Tasks.UaInspector.Verify do
  @moduledoc """
  Verifies UAInspector results.
  """

  @shortdoc "Verifies parser results"

  use Mix.Task

  alias UAInspector.Config
  alias UAInspector.Downloader
  alias UAInspectorVerify.Cleanup
  alias UAInspectorVerify.Fixtures
  alias UAInspectorVerify.Verify

  def run(args) do
    {opts, _argv, _errors} =
      OptionParser.parse(args, strict: [remote_release: :string, quick: :boolean])

    opts = Map.new(opts)

    :ok = setup_remote_release(opts)
    :ok = maybe_download(opts)

    {:ok, _} = Application.ensure_all_started(:ua_inspector)

    Mix.shell().info(["Verification remote release: ", Config.remote_release()])

    :ok =
      verify_all(
        &Fixtures.Custom.list/0,
        &Fixtures.Custom.download_path/1,
        &Function.identity/1,
        &UAInspector.Parser.parse/2,
        &Verify.Custom.verify/2
      )

    :ok =
      verify_all(
        &Fixtures.Client.list/0,
        &Fixtures.Client.download_path/1,
        &Cleanup.Client.cleanup/1,
        &UAInspector.Parser.Client.parse/2,
        &Verify.Client.verify/2
      )

    :ok =
      verify_all(
        &Fixtures.ClientHints.list/0,
        &Fixtures.ClientHints.download_path/1,
        &Cleanup.Generic.cleanup/1,
        &UAInspector.Parser.parse/2,
        &Verify.ClientHints.verify/2
      )

    :ok =
      verify_all(
        &Fixtures.Device.list/0,
        &Fixtures.Device.download_path/1,
        &Cleanup.Device.cleanup/1,
        &UAInspector.Parser.Device.parse/2,
        &Verify.Device.verify/2
      )

    :ok =
      verify_all(
        &Fixtures.OS.list/0,
        &Fixtures.OS.download_path/1,
        &Cleanup.OS.cleanup/1,
        &UAInspector.Parser.OS.parse/2,
        &Verify.OS.verify/2
      )

    :ok =
      verify_all(
        &Fixtures.VendorFragment.list/0,
        &Fixtures.VendorFragment.download_path/1,
        &Cleanup.VendorFragment.cleanup/1,
        &UAInspector.Parser.VendorFragment.parse/2,
        &Verify.VendorFragment.verify/2
      )

    :ok =
      verify_all(
        &Fixtures.Generic.list/0,
        &Fixtures.Generic.download_path/1,
        &Cleanup.Generic.cleanup/1,
        &UAInspector.Parser.parse/2,
        &Verify.Generic.verify/2
      )

    :ok =
      verify_all(
        &Fixtures.TypeMethods.list/0,
        &Fixtures.TypeMethods.download_path/1,
        &Function.identity/1,
        &UAInspector.Parser.parse/2,
        &Verify.TypeMethods.verify/2
      )

    Mix.shell().info("Verification complete!")
    :ok
  end

  defp maybe_download(%{quick: true}), do: :ok

  defp maybe_download(_) do
    {:ok, _} = Application.ensure_all_started(:hackney)
    :ok = Downloader.download()

    :ok = Fixtures.Client.download()
    :ok = Fixtures.ClientHints.download()
    :ok = Fixtures.Device.download()
    :ok = Fixtures.OS.download()
    :ok = Fixtures.VendorFragment.download()

    :ok = Fixtures.Generic.download()
    :ok = Fixtures.TypeMethods.download()

    Mix.shell().info("=== Skip downloads using '--quick' ===")

    :ok
  end

  defp parse([case_entry | _] = case_data) when is_tuple(case_entry) do
    Enum.into(case_data, %{}, fn {k, v} -> {String.to_atom(k), parse(v)} end)
  end

  defp parse(case_data), do: case_data

  defp setup_remote_release(%{remote_release: remote_release}) when is_binary(remote_release),
    do: Application.put_env(:ua_inspector, :remote_release, remote_release)

  defp setup_remote_release(_), do: :ok

  defp verify(_, [], _, _, _), do: :ok

  defp verify(fixture, [testcase | testcases], fun_cleanup, fun_parse, fun_verify) do
    testcase = testcase |> parse() |> fun_cleanup.()

    client_hints =
      case testcase[:headers] do
        nil -> nil
        headers -> UAInspector.ClientHints.new(headers)
      end

    result = fun_parse.(testcase[:user_agent], client_hints)

    if fun_verify.(testcase, result) do
      verify(fixture, testcases, fun_cleanup, fun_parse, fun_verify)
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

  defp verify_all(fun_fixtures, fun_download, fun_cleanup, fun_parse, fun_verify) do
    fun_fixtures.()
    |> Task.async_stream(&verify_fixture(&1, fun_download, fun_cleanup, fun_parse, fun_verify),
      timeout: :infinity
    )
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

  defp verify_fixture(fixture, fun_download, fun_cleanup, fun_parse, fun_verify) do
    testfile = fun_download.(fixture)

    if File.exists?(testfile) do
      [testcases] = :yamerl_constr.file(testfile, [:str_node_as_binary])

      Mix.shell().info(".. verifying: #{fixture} (#{length(testcases)} tests)")
      verify(fixture, testcases, fun_cleanup, fun_parse, fun_verify)
    else
      {:error, fixture, :enoent}
    end
  end
end
