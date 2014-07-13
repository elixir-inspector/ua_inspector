defmodule ExAgent.Response.UA do
  @type t :: %__MODULE__{
    family: String.t | atom,
    major:  String.t | atom,
    minor:  String.t | atom,
    patch:  String.t | atom
  }

  defstruct family: :unknown,
            major:  :unknown,
            minor:  :unknown,
            patch:  :unknown
end
