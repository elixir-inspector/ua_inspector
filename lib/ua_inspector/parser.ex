defmodule UAInspector.Parser do
  @moduledoc """
  Parser module to call individual data parsers and aggregate the results.
  """

  use Behaviour

  alias UAInspector.Database
  alias UAInspector.Parser

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  @doc """
  Parses information from a user agent.

  Returns `:unknown` if no information is not found in the database.

      iex> parse("--- undetectable ---", [])
      :unknown
  """
  defcallback parse(String.t, Enum.t) :: atom | map

  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t) :: map
  def parse(ua) do
    %{
      user_agent: ua,
      client:     Parser.Client.parse(ua, Database.Clients.list),
      device:     Parser.Device.parse(ua, Database.Devices.list),
      os:         Parser.Os.parse(ua, Database.Oss.list)
    }
  end
end
