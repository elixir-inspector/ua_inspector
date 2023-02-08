defmodule UAInspector.Parser.Behaviour do
  @moduledoc false

  alias UAInspector.ClientHints

  @doc """
  Parses information from a user agent.

  Returns `:unknown` if no information is not found in the database.

      iex> parse("--- undetectable ---")
      :unknown

  """
  @callback parse(ua :: String.t(), client_hints :: ClientHints.t() | nil) :: atom | binary | map
end
