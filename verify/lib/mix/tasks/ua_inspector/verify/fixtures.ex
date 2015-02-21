defmodule Mix.Tasks.Ua_inspector.Verify.Fixtures do
  @moduledoc """
  Utility module to bundle/download verification fixtures.
  """

  @fixtures [
    { "car_browser.yml", "https://raw.githubusercontent.com/piwik/device-detector/master/Tests/fixtures/car_browser.yml" }
  ]

  def download() do
    Mix.shell.info "Download path: #{ download_path }"

    setup()
    download(@fixtures)

    Mix.shell.info "Download complete!"
    :ok
  end

  def download([]),                             do: :ok
  def download([{ local, remote } | fixtures ]) do
    target = Path.join([ download_path, local ])

    Mix.shell.info ".. downloading: #{ local }"
    File.write! target, Mix.Utils.read_path!(remote)

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
