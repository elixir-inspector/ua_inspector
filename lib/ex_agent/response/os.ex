defmodule ExAgent.Response.OS do
  @type t :: map

  defstruct family:      :unknown :: String.t | atom,
            major:       :unknown :: String.t | atom,
            minor:       :unknown :: String.t | atom,
            patch:       :unknown :: String.t | atom,
            patch_minor: :unknown :: String.t | atom
end
