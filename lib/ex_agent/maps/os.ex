defmodule ExAgent.OS do
  defstruct family:  :unknown :: String.t | atom,
            version: :unknown :: String.t | atom
end
