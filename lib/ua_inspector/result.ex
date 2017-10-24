defmodule UAInspector.Result do
  @moduledoc """
  Result struct.
  """

  alias UAInspector.Result

  @type t :: %__MODULE__{
          user_agent: String.t(),
          client: Result.Client.t() | :unknown,
          device: Result.Device.t() | :unknown,
          os: Result.OS.t() | :unknown
        }

  defstruct user_agent: "",
            client: :unknown,
            device: :unknown,
            os: :unknown
end
