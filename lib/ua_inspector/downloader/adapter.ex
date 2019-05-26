defmodule UAInspector.Downloader.Adapter do
  @moduledoc """
  Behaviour for modules used by the downloader.
  """

  @doc """
  Reads a database file from a remote location and returns it's contents.
  """
  @callback read_remote(location :: binary) :: {:ok, contents :: binary} | {:error, term}
end
