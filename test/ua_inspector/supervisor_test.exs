defmodule UAInspector.SupervisorTest do
  use ExUnit.Case, async: false

  alias UAInspector.Config

  import ExUnit.CaptureLog

  defmodule Initializer do
    use Agent

    def start_link(_), do: Agent.start_link(fn -> nil end, name: __MODULE__)

    def call_init, do: call_init(:ok_empty)
    def call_init(result), do: Agent.update(__MODULE__, fn _ -> result end)

    def get_init, do: Agent.get(__MODULE__, & &1)
  end

  setup do
    init = Application.get_env(:ua_inspector, :init)
    startup_silent = Application.get_env(:ua_inspector, :startup_silent)

    on_exit(fn ->
      :ok = Application.put_env(:ua_inspector, :init, init)
      :ok = Application.put_env(:ua_inspector, :startup_silent, startup_silent)
    end)
  end

  test "init {mod, fun} called upon supervisor (re-) start" do
    {:ok, _} = start_supervised(Initializer)

    capture_log(fn ->
      Supervisor.stop(UAInspector.Supervisor, :normal)

      :ok = :timer.sleep(100)
      :ok = Application.put_env(:ua_inspector, :init, {Initializer, :call_init})
      {:ok, _} = Application.ensure_all_started(:ua_inspector)
      :ok = :timer.sleep(100)

      assert :ok_empty = Initializer.get_init()
    end)
  end

  test "init {mod, fun, args} called upon supervisor (re-) start" do
    {:ok, _} = start_supervised(Initializer)

    capture_log(fn ->
      Supervisor.stop(UAInspector.Supervisor, :normal)

      :ok = :timer.sleep(100)
      :ok = Application.put_env(:ua_inspector, :init, {Initializer, :call_init, [:ok_passed]})
      {:ok, _} = Application.ensure_all_started(:ua_inspector)
      :ok = :timer.sleep(100)

      assert :ok_passed = Initializer.get_init()
    end)
  end

  test "logs if release tracking file contains non-default version" do
    release = "0.0.0-test"
    release_file = Path.join(Config.database_path(), "ua_inspector.release")

    log =
      capture_log(fn ->
        File.write!(release_file, release)
        Supervisor.stop(UAInspector.Supervisor, :normal)

        :ok = :timer.sleep(100)
        :ok = Application.put_env(:ua_inspector, :startup_silent, false)
        {:ok, _} = Application.ensure_all_started(:ua_inspector)
        :ok = :timer.sleep(100)

        File.rm!(release_file)
      end)

    assert String.contains?(log, release)
    assert String.contains?(log, Config.remote_release())
  end

  test "does not log if release tracking file contains default version" do
    release = Config.remote_release()
    release_file = Path.join(Config.database_path(), "ua_inspector.release")

    log =
      capture_log(fn ->
        File.write!(release_file, release)
        Supervisor.stop(UAInspector.Supervisor, :normal)

        :ok = :timer.sleep(100)
        :ok = Application.put_env(:ua_inspector, :startup_silent, false)
        {:ok, _} = Application.ensure_all_started(:ua_inspector)
        :ok = :timer.sleep(100)

        File.rm!(release_file)
      end)

    refute String.contains?(log, release)
  end
end
