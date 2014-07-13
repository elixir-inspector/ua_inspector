defmodule ExAgent.Response.Device do
  @type t :: %__MODULE__{
    family: String.t | atom
  }

  defstruct family: :unknown
end
