defmodule Mix.UAInspector.Verify.Fixtures do
  @moduledoc """
  Utility module to bundle/download verification fixtures.
  """

  alias UAInspector.Config

  @fixture_base_url "https://raw.githubusercontent.com/matomo-org/device-detector/master/Tests/fixtures"

  @fixtures [
    "bots.yml",
    "camera.yml",
    "car_browser.yml",
    "console.yml",
    "desktop.yml",
    "feature_phone.yml",
    "feed_reader.yml",
    "mediaplayer.yml",
    "mobile_apps.yml",
    "phablet.yml",
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
    "tablet.yml",
    "tablet-1.yml",
    "tablet-2.yml",
    "tablet-3.yml",
    "tv.yml",
    "unknown.yml"
  ]

  def download do
    Mix.shell().info("Download path: #{download_path()}")

    setup()
    download(@fixtures)

    Mix.shell().info("Download complete!")
    :ok
  end

  def download([]), do: :ok

  def download([fixture | fixtures]) do
    Mix.shell().info(".. downloading: #{fixture}")

    remote = "#{@fixture_base_url}/#{fixture}"
    local = download_path(fixture)

    download_fixture(remote, local)
    download(fixtures)
  end

  defp download_fixture(remote, local) do
    {:ok, content} = Config.downloader_adapter().read_remote(remote)

    File.write!(local, content)
  end

  def download_path, do: Path.expand("../../../../fixtures", __DIR__)
  def download_path(file), do: Path.join(download_path(), file)
  def list, do: @fixtures

  def setup do
    File.rm_rf!(download_path())
    File.mkdir_p!(download_path())
  end
end
