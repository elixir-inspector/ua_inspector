defmodule UAInspector.Database.State do
  @moduledoc """
  State definition for databases.
  """

  defstruct [
    ets_counter: nil,
    ets_tid:     nil
  ]

  @opaque t :: %__MODULE__{
    ets_counter: :ets.tid,
    ets_tid:     :ets.tid
  }
end
