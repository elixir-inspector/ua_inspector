defmodule ExAgent.Response do
  @type t :: %__MODULE__{
    string: String.t,
    device: ExAgent.Response.Device,
    os:     ExAgent.Response.OS,
    ua:     ExAgent.Response.UA
  }

  defstruct string: nil,
            device: nil,
            os:     nil,
            ua:     nil
end
