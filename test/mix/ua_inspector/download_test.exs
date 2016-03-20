defmodule Mix.UAInspector.DownloadTest do
  use ExUnit.Case, async: false

  test "database path readme creation" do
    orig_path = Application.get_env(:ua_inspector, :database_path)
    test_path = Path.join(__DIR__, "../../downloads") |> Path.expand()

    Application.put_env(:ua_inspector, :database_path, test_path)
    Mix.UAInspector.Download.prepare_database_path()
    Application.put_env(:ua_inspector, :database_path, orig_path)

    orig_readme = Path.join(__DIR__, "../../../lib/mix/files/README.md") |> Path.expand()
    test_readme = Path.join(test_path, "README.md") |> Path.expand()

    assert File.exists?(test_readme)
    assert File.stat!(orig_readme).size == File.stat!(test_readme).size

    File.rm_rf! test_path
  end
end
