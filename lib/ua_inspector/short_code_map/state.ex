defmodule UAInspector.ShortCodeMap.State do
  @moduledoc """
  State definition for short code maps.
  """

  defstruct [
    ets_tid: nil
  ]

  @opaque t :: %__MODULE__{
    ets_tid: :ets.tid
  }
end
