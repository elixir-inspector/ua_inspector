defmodule Mix.Tasks.UAInspector.Verify.Fixtures do
  @moduledoc """
  Utility module to bundle/download verification fixtures.
  """

  @fixture_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/Tests/fixtures"

  @fixtures [
    "camera.yml",
    "car_browser.yml",
    "console.yml"
  ]

  def download() do
    Mix.shell.info "Download path: #{ download_path }"

    setup()
    download(@fixtures)

    Mix.shell.info "Download complete!"
    :ok
  end

  def download([]),                    do: :ok
  def download([ fixture | fixtures ]) do
    target = Path.join([ download_path, fixture ])

    Mix.shell.info ".. downloading: #{ fixture }"
    File.write! target, Mix.Utils.read_path!("#{ @fixture_base_url }/#{ fixture }")

    download(fixtures)
  end

  def download_path,       do: Path.join(__DIR__, "../../../../../fixtures")
  def download_path(file), do: Path.join(download_path, file)
  def list,                do: @fixtures

  def setup() do
    File.rm_rf! download_path
    File.mkdir_p! download_path
  end
end
