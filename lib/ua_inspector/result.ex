defmodule UAInspector.Result do
  @moduledoc """
  Result struct.
  """

  alias UAInspector.Result

  @type t :: %__MODULE__{
          user_agent: nil | String.t(),
          browser_family: String.t() | :unknown,
          client: Result.Client.t() | :unknown,
          device: Result.Device.t() | :unknown,
          os: Result.OS.t() | :unknown,
          os_family: String.t() | :unknown
        }

  defstruct user_agent: nil,
            browser_family: :unknown,
            client: :unknown,
            device: :unknown,
            os: :unknown,
            os_family: :unknown
end
