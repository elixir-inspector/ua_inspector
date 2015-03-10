defmodule UAInspector.Result.Client do
  @moduledoc """
  Client result struct.
  """

  defstruct [
    engine:  :unknown,
    name:    :unknown,
    type:    :unknown,
    version: :unknown
  ]
end
