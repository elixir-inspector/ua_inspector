defmodule UAInspector.Result.Bot do
  @moduledoc """
  Bot result struct.
  """

  @type t :: %__MODULE__{
          user_agent: String.t(),
          name: String.t() | :unknown,
          category: String.t() | :unknown,
          url: String.t() | :unknown,
          producer: UAInspector.Result.BotProducer.t()
        }

  defstruct user_agent: "",
            name: :unknown,
            category: :unknown,
            url: :unknown,
            producer: %UAInspector.Result.BotProducer{}
end
