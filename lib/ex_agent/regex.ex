defmodule ExAgent.Regex do
  @type t :: %__MODULE__{
    regex:              Regex.t,
    device_replacement: String.t,
    family_replacement: String.t,
    os_replacement:     String.t,
    os_v1_replacement:  String.t,
    os_v2_replacement:  String.t,
    v1_replacement:     String.t,
    v2_replacement:     String.t
  }

  defstruct regex:              nil,
            device_replacement: nil,
            family_replacement: nil,
            os_replacement:     nil,
            os_v1_replacement:  nil,
            os_v2_replacement:  nil,
            v1_replacement:     nil,
            v2_replacement:     nil
end
