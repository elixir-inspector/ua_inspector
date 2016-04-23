defmodule UAInspector.Result do
  @moduledoc """
  Result struct.
  """

  alias UAInspector.Result

  defstruct [
    user_agent: "",
    client:     :unknown,
    device:     :unknown,
    os:         :unknown
  ]
end
