defmodule ExAgent.Response.UserAgent do
  defstruct family:  :unknown :: String.t | atom,
            version: :unknown :: String.t | atom
end
