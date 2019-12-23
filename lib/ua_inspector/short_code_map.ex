defmodule UAInspector.ShortCodeMap do
  @moduledoc false

  @doc """
  Returns the local and remote sources for this map.
  """
  @callback source() :: {binary, binary}

  @doc """
  Returns a name representation for this map.
  """
  @callback var_name() :: String.t()

  @doc """
  Returns a type representation for this map.
  """
  @callback var_type() :: :hash | :list | :hash_with_list
end
