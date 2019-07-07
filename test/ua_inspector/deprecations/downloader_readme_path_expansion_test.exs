defmodule UAInspector.Deprecations.DownloaderREADMEPathExpansionTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.Downloader.README

  test "path_local/0" do
    assert capture_log(fn ->
             _ = README.path_local()
           end) =~ ~r/declared internal/i
  end

  test "path_priv" do
    assert capture_log(fn ->
             _ = README.path_priv()
           end) =~ ~r/declared internal/i
  end
end
