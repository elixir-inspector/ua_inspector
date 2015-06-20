defmodule UAInspector.ShortCodeMaps do
  @moduledoc """
  Module to coordinate individual parser short code maps.
  """

  use GenServer

  alias UAInspector.ShortCodeMap


  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  def init(_) do
    ShortCodeMap.DeviceBrands.init()
    ShortCodeMap.OSs.init()

    ShortCodeMap.DeviceBrands.load()
    ShortCodeMap.OSs.load()

    { :ok, [] }
  end
end
