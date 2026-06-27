defmodule UAInspector.Downloader.Adapter.Hackney do
  @moduledoc false

  @dialyzer [{:nowarn_function, read_body: 1}]

  alias UAInspector.Config

  @behaviour UAInspector.Downloader.Adapter

  @impl UAInspector.Downloader.Adapter
  def read_remote(location) do
    _ = Application.ensure_all_started(:hackney)

    http_opts = Config.get(:http_opts, [])

    case :hackney.get(location, [], [], http_opts) do
      {:ok, 200, _, body} -> read_body(body)
      {:ok, status, _, _} -> {:error, {:status, status, location}}
      {:error, _} = error -> error
    end
  end

  defp read_body(body) when is_reference(body), do: :hackney.body(body)
  defp read_body(body), do: {:ok, body}
end
