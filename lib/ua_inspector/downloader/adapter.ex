defmodule UAInspector.Downloader.Adapter do
  @moduledoc """
  Behaviour for modules used by the downloader.

  The default adapter is `UAInspector.Downloader.Adapter.Hackney`. A custom
  implementation can be configured using the `:downloader_adapter` option.
  """

  @doc """
  Reads a database file from a remote location and returns its contents.
  """
  @callback read_remote(location :: binary) :: {:ok, contents :: binary} | {:error, term}
end
