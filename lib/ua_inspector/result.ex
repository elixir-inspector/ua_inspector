defmodule UAInspector.Result do
  @moduledoc """
  Result struct.
  """

  defstruct [
    user_agent: "",
    client:     :unknown,
    device:     :unknown,
    os:         :unknown
  ]
end
