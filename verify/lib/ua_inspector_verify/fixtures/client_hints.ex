defmodule UAInspectorVerify.Fixtures.ClientHints do
  @moduledoc false

  alias UAInspector.Config

  @fixture_base "https://raw.githubusercontent.com/matomo-org/device-detector/"
  @fixture_path "/Tests/fixtures/"

  @fixtures_default [
    "clienthints-app.yml"
  ]

  @fixtures_release %{
    "master" => []
  }

  def download do
    Mix.shell().info("Download path: #{download_path()}")

    setup()
    download(list())

    Mix.shell().info("Download complete!")
    :ok
  end

  def download([]), do: :ok

  def download([fixture | fixtures]) do
    Mix.shell().info(".. downloading: #{fixture}")

    remote = @fixture_base <> Config.remote_release() <> @fixture_path <> fixture
    local = download_path(fixture)

    download_fixture(remote, local)
    download(fixtures)
  end

  defp download_fixture(remote, local) do
    {:ok, content} = Config.downloader_adapter().read_remote(remote)

    File.write!(local, content)
  end

  def download_path, do: Path.expand("../../../priv/fixtures/client_hints", __DIR__)
  def download_path(file), do: Path.join(download_path(), file)

  def list do
    @fixtures_release
    |> Map.get(Config.remote_release(), [])
    |> Enum.concat(@fixtures_default)
  end

  def setup do
    File.rm_rf!(download_path())
    File.mkdir_p!(download_path())
  end
end
