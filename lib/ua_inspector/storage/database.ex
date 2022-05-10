defmodule UAInspector.Storage.Database do
  @moduledoc false

  @doc """
  Returns the database sources.
  """
  @callback sources() :: [{binary, binary, binary}]
end
