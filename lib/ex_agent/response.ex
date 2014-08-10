defmodule ExAgent.Response do
  @type t :: %__MODULE__{
    string: String.t,
    client: Map.t,
    device: Map.t,
    os:     Map.t
  }

  defstruct string: nil,
            client: nil,
            device: nil,
            os:     nil
end
