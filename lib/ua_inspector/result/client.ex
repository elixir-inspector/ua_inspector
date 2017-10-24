defmodule UAInspector.Result.Client do
  @moduledoc """
  Client result struct.
  """

  @type t :: %__MODULE__{
          engine: String.t() | :unknown,
          engine_version: String.t() | :unknown,
          name: String.t() | :unknown,
          type: String.t() | :unknown,
          version: String.t() | :unknown
        }

  defstruct engine: :unknown,
            engine_version: :unknown,
            name: :unknown,
            type: :unknown,
            version: :unknown
end
