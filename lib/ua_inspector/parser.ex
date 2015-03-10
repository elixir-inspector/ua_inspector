defmodule UAInspector.Parser do
  @moduledoc """
  Parser module to call individual data parsers and aggregate the results.
  """

  use Behaviour

  alias UAInspector.Parser
  alias UAInspector.Result

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  @doc """
  Parses information from a user agent.

  Returns `:unknown` if no information is not found in the database.

      iex> parse("--- undetectable ---")
      :unknown
  """
  defcallback parse(ua :: String.t) :: atom | map

  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t) :: map
  def parse(ua) do
    %Result{
      user_agent: ua,
      client:     Parser.Client.parse(ua),
      device:     Parser.Device.parse(ua),
      os:         Parser.OS.parse(ua)
    }
  end
end
