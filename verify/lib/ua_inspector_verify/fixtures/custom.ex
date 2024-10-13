defmodule UAInspectorVerify.Fixtures.Custom do
  @moduledoc """
  Custom verification fixtures.
  """

  @files [
    "regression.yml"
  ]

  def download, do: :ok
  def download_path, do: Path.expand("../../../fixtures/", __DIR__)
  def download_path(file), do: Path.join(download_path(), file)
  def list, do: @files
  def setup, do: :ok
end
