defmodule UAInspector.Storage.State do
  @moduledoc """
  State definition for storage processes.
  """

  defstruct ets_tid: nil

  @opaque t :: %__MODULE__{
            ets_tid: :ets.tid()
          }
end
