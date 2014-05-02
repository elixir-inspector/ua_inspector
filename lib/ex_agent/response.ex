defmodule ExAgent.Response do
  defstruct string: nil :: String.t,
            device: nil :: ExAgent.Response.Device,
            os:     nil :: ExAgent.Response.OS,
            ua:     nil :: ExAgent.Response.UserAgent
end
