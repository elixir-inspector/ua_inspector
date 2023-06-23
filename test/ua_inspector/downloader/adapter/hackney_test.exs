defmodule UAInspector.Downloader.Adapter.HackneyTest do
  use ExUnit.Case, async: true

  alias UAInspector.Downloader.Adapter.Hackney

  test "errors returned from adapter" do
    assert {:error, :nxdomain} = Hackney.read_remote("invalid")
  end

  test "requires HTTP 200 responses for success" do
    httpd_opts = [
      port: 0,
      server_name: ~c"ua_inspector_hackney_test",
      server_root: String.to_charlist(__DIR__),
      document_root: String.to_charlist(__DIR__)
    ]

    {:ok, httpd_pid} = :inets.start(:httpd, httpd_opts)

    location = "http://localhost:#{:httpd.info(httpd_pid)[:port]}/--does-not-exist--"

    assert {:error, {:status, 404, ^location}} = Hackney.read_remote(location)

    :inets.stop(:httpd, httpd_pid)
  end
end
