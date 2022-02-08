defmodule UAInspector.ReloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  test "reloading databases" do
    agent =
      "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"

    unknown = %UAInspector.Result{user_agent: agent}
    db_path = Application.get_env(:ua_inspector, :database_path)

    Application.delete_env(:ua_inspector, :database_path)

    capture_log(fn ->
      UAInspector.reload(async: false)
    end)

    refute UAInspector.ready?()
    assert ^unknown = UAInspector.parse(agent)

    Application.put_env(:ua_inspector, :database_path, db_path)
    UAInspector.reload()
    :timer.sleep(100)

    assert UAInspector.ready?()
    refute unknown == UAInspector.parse(agent)
  end
end
