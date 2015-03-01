defmodule UAInspector.Result.Device do
  @moduledoc """
  Device result struct.
  """

  defstruct [
    brand: :unknown,
    model: :unknown,
    type:  :unknown
  ]
end
