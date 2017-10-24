defmodule UAInspector.Result.Device do
  @moduledoc """
  Device result struct.
  """

  @type t :: %__MODULE__{
          brand: String.t() | :unknown,
          model: String.t() | :unknown,
          type: String.t() | :unknown
        }

  defstruct brand: :unknown,
            model: :unknown,
            type: :unknown
end
