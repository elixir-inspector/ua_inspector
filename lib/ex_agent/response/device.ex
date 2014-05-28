defmodule ExAgent.Response.Device do
  @type t :: map

  defstruct family: :unknown :: String.t | atom
end
