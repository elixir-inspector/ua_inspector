defmodule UAInspector.Downloader.Adapter.HackneyTest do
  use ExUnit.Case, async: true

  alias UAInspector.Downloader.Adapter.Hackney

  test "errors returned from adapter" do
    assert Hackney.read_remote("invalid") == {:error, :nxdomain}
  end
end
