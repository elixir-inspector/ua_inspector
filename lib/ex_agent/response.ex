defmodule ExAgent.Response do
  @type t :: map

  defstruct string: nil :: String.t,
            device: nil :: ExAgent.Response.Device,
            os:     nil :: ExAgent.Response.OS,
            ua:     nil :: ExAgent.Response.UA
end
