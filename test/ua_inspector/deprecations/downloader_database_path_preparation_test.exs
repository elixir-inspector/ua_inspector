defmodule UAInspector.Deprecations.DownloaderDatabasePathPreparationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.Downloader

  test "prepare_database_path/0" do
    assert capture_log(fn ->
             _ = Downloader.prepare_database_path()
           end) =~ ~r/declared internal/i
  end
end
