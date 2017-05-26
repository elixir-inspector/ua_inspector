defmodule UAInspector do
  @moduledoc """
  UA Inspector - User agent parser library
  """

  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(String.t) :: boolean
  defdelegate bot?(ua), to: UAInspector.Pool

  @doc """
  Checks if a user agent is a HbbTV and returns its version if so.
  """
  @spec hbbtv?(String.t) :: false | String.t
  defdelegate hbbtv?(ua), to: UAInspector.Pool

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: map
  defdelegate parse(ua), to: UAInspector.Pool

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t) :: map
  defdelegate parse_client(ua), to: UAInspector.Pool
end
