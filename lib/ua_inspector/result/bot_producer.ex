defmodule UAInspector.Result.BotProducer do
  @moduledoc """
  Bot producer result struct.
  """

  @type t :: %__MODULE__{
          name: String.t() | :unknown,
          url: String.t() | :unknown
        }

  defstruct name: :unknown,
            url: :unknown
end
