defmodule ExAgent.Regex do
  @type t :: map

  defstruct regex:              nil :: Regex.t,
            device_replacement: nil :: String.t,
            family_replacement: nil :: String.t,
            os_replacement:     nil :: String.t,
            os_v1_replacement:  nil :: String.t,
            os_v2_replacement:  nil :: String.t,
            v1_replacement:     nil :: String.t,
            v2_replacement:     nil :: String.t
end
