defmodule ExAgent.Response.UA do
  defstruct family: :unknown :: String.t | atom,
            major:  :unknown :: String.t | atom,
            minor:  :unknown :: String.t | atom,
            patch:  :unknown :: String.t | atom
end
