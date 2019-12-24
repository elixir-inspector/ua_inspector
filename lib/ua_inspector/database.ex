defmodule UAInspector.Database do
  @moduledoc false

  @doc """
  Returns the database sources.
  """
  @callback sources() :: [{binary, binary, binary}]

  @doc """
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any, type :: String.t()) :: term
end
