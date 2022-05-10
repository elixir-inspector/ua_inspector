defmodule UAInspector.Storage.ClientHints do
  @moduledoc false

  @doc """
  Returns the local and remote sources for this type.
  """
  @callback source() :: {binary, binary}
end
