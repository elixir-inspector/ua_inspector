defmodule UAInspectorVerify.Fixtures.Generic do
  @moduledoc """
  Utility module to bundle/download verification fixtures.
  """

  alias UAInspector.Config

  @fixture_base "https://raw.githubusercontent.com/matomo-org/device-detector/"
  @fixture_path "/Tests/fixtures/"

  @fixtures_default [
    "bots.yml",
    "camera.yml",
    "car_browser.yml",
    "clienthints.yml",
    "console.yml",
    "desktop.yml",
    "desktop-1.yml",
    "feature_phone.yml",
    "feed_reader.yml",
    "mediaplayer.yml",
    "mobile_apps.yml",
    "peripheral.yml",
    "phablet.yml",
    "phablet-1.yml",
    "podcasting.yml",
    "portable_media_player.yml",
    "smart_display.yml",
    "smart_speaker.yml",
    "smartphone.yml",
    "smartphone-1.yml",
    "smartphone-2.yml",
    "smartphone-3.yml",
    "smartphone-4.yml",
    "smartphone-5.yml",
    "smartphone-6.yml",
    "smartphone-7.yml",
    "smartphone-8.yml",
    "smartphone-9.yml",
    "smartphone-10.yml",
    "smartphone-11.yml",
    "smartphone-12.yml",
    "smartphone-13.yml",
    "smartphone-14.yml",
    "smartphone-15.yml",
    "smartphone-16.yml",
    "smartphone-17.yml",
    "smartphone-18.yml",
    "smartphone-19.yml",
    "smartphone-20.yml",
    "smartphone-21.yml",
    "smartphone-22.yml",
    "smartphone-23.yml",
    "smartphone-24.yml",
    "smartphone-25.yml",
    "smartphone-26.yml",
    "smartphone-27.yml",
    "smartphone-28.yml",
    "smartphone-29.yml",
    "smartphone-30.yml",
    "smartphone-31.yml",
    "smartphone-32.yml",
    "smartphone-33.yml",
    "smartphone-34.yml",
    "smartphone-35.yml",
    "smartphone-36.yml",
    "smartphone-37.yml",
    "smartphone-38.yml",
    "smartphone-39.yml",
    "smartphone-40.yml",
    "smartphone-41.yml",
    "smartphone-42.yml",
    "tablet.yml",
    "tablet-1.yml",
    "tablet-2.yml",
    "tablet-3.yml",
    "tablet-4.yml",
    "tablet-5.yml",
    "tablet-6.yml",
    "tablet-7.yml",
    "tablet-8.yml",
    "tablet-9.yml",
    "tablet-10.yml",
    "tablet-11.yml",
    "tablet-12.yml",
    "tv.yml",
    "tv-1.yml",
    "tv-2.yml",
    "tv-3.yml",
    "tv-4.yml",
    "tv-5.yml",
    "unknown.yml",
    "wearable.yml"
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

  def download_path, do: Path.expand("../../../priv/fixtures/generic", __DIR__)
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
