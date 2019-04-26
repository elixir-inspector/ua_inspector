defmodule UAInspector.SupervisorTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  defmodule Initializer do
    use Agent

    def start_link(_), do: Agent.start_link(fn -> nil end, name: __MODULE__)

    def call_init, do: call_init(:ok_empty)
    def call_init(result), do: Agent.update(__MODULE__, fn _ -> result end)

    def get_init, do: Agent.get(__MODULE__, & &1)
  end

  setup_all do
    init = Application.get_env(:ua_inspector, :init)

    on_exit(fn ->
      :ok = Application.put_env(:ua_inspector, :init, init)
    end)
  end

  test "init {mod, fun} called upon supervisor (re-) start" do
    start_supervised(Initializer)

    capture_log(fn ->
      Supervisor.stop(UAInspector.Supervisor, :normal)

      :ok = :timer.sleep(100)
      :ok = Application.put_env(:ua_inspector, :init, {Initializer, :call_init})
      {:ok, _} = Application.ensure_all_started(:ua_inspector)
      :ok = :timer.sleep(100)

      assert :ok_empty == Initializer.get_init()
    end)
  end

  test "init {mod, fun, args} called upon supervisor (re-) start" do
    start_supervised(Initializer)

    capture_log(fn ->
      Supervisor.stop(UAInspector.Supervisor, :normal)

      :ok = :timer.sleep(100)
      :ok = Application.put_env(:ua_inspector, :init, {Initializer, :call_init, [:ok_passed]})
      {:ok, _} = Application.ensure_all_started(:ua_inspector)
      :ok = :timer.sleep(100)

      assert :ok_passed == Initializer.get_init()
    end)
  end
end
