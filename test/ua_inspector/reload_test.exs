defmodule UAInspector.ReloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "reloading databases" do
    agent =
      "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"

    app_database_path = Application.get_env(:ua_inspector, :database_path)
    unknown = %UAInspector.Result{user_agent: agent}

    capture_io(:user, fn ->
      Application.put_env(:ua_inspector, :database_path, __DIR__)
      restart_supervisor()
      Logger.flush()
    end)

    assert UAInspector.parse(agent) == unknown

    Application.put_env(:ua_inspector, :database_path, app_database_path)
    UAInspector.reload()
    :timer.sleep(100)

    refute UAInspector.parse(agent) == unknown
  end

  defp restart_supervisor() do
    :ok = Supervisor.stop(UAInspector.Supervisor, :normal)
    :ok = :timer.sleep(50)

    _ = Application.ensure_all_started(:ua_inspector)

    :ok = :timer.sleep(50)
    :ok
  end
end
