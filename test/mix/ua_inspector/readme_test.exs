defmodule Mix.UAInspector.READMETest do
  use ExUnit.Case, async: false

  alias Mix.UAInspector.README

  setup_all do
    orig_path = Application.get_env(:ua_inspector, :database_path)
    test_path = Path.join(__DIR__, "../../downloads") |> Path.expand()

    :ok = Application.put_env(:ua_inspector, :database_path, test_path)
    _ = File.rm_rf!(test_path)

    on_exit(fn ->
      _ = File.rm_rf!(test_path)
      :ok = Application.put_env(:ua_inspector, :database_path, orig_path)
    end)
  end

  test "database path readme creation" do
    refute File.exists?(README.path_local())

    README.write()

    assert File.exists?(README.path_local())
  end
end
