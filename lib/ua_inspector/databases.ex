defmodule UAInspector.Databases do
  @moduledoc """
  Module to coordinate individual parser databases.
  """

  alias UAInspector.Database

  @doc """
  Sends a request to load databases.
  """
  @spec load(String.t) :: :ok
  def load(nil), do: :ok
  def load(path) do
    :ok = Database.Bots.load(path)
    :ok = Database.BrowserEngines.load(path)
    :ok = Database.Clients.load(path)
    :ok = Database.Devices.load(path)
    :ok = Database.OSs.load(path)
    :ok = Database.VendorFragments.load(path)

    :ok
  end
end
