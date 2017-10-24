defmodule UAInspector.Result.OS do
  @moduledoc """
  Operating system result struct.
  """

  @type t :: %__MODULE__{
          name: String.t() | :unknown,
          platform: String.t() | :unknown,
          version: String.t() | :unknown
        }

  defstruct name: :unknown,
            platform: :unknown,
            version: :unknown
end
