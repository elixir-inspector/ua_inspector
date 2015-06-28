defmodule UAInspector.Result.Bot do
  @moduledoc """
  Bot result struct.
  """

  defstruct [
    user_agent: "",
    name:       :unknown,
    category:   :unknown,
    url:        :unknown,
    producer:   %UAInspector.Result.BotProducer{}
  ]
end
