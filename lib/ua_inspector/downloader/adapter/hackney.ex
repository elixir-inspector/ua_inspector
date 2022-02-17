defmodule UAInspector.Downloader.Adapter.Hackney do
  @moduledoc false

  alias UAInspector.Config

  @behaviour UAInspector.Downloader.Adapter

  @doc """
  Reads a remote file and returns it's contents.
  """
  @spec read_remote(binary) :: {:ok, binary} | {:error, term}
  def read_remote(location) do
    _ = Application.ensure_all_started(:hackney)

    http_opts = Config.get(:http_opts, [])

    case :hackney.get(location, [], [], http_opts) do
      {:ok, 200, _, client} -> :hackney.body(client)
      {:ok, status, _, _} -> {:error, {:status, status, location}}
      {:error, _} = error -> error
    end
  end
end
