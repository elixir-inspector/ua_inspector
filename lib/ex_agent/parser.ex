defmodule ExAgent.Parser do
  @moduledoc """
  Parser module to call individual data parsers and aggregate the results.
  """

  use Behaviour

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
      string: ua,
      client: ExAgent.Parser.Client.parse(ua, ExAgent.Database.Clients.list),
      device: ExAgent.Parser.Device.parse(ua, ExAgent.Database.Devices.list),
      os:     ExAgent.Parser.Os.parse(ua, ExAgent.Database.Oss.list)
    }
  end
end
