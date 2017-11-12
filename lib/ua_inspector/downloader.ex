defmodule UAInspector.Downloader do
  @moduledoc """
  File download utility module.
  """

  alias UAInspector.Config

  @doc """
  Reads a remote file and returns it's contents.
  """
  @spec read_remote(String.t()) :: term
  def read_remote(path) do
    http_opts = Config.get(:http_opts, [])
    {:ok, _, _, client} = :hackney.get(path, [], [], http_opts)

    :hackney.body(client)
  end
end
