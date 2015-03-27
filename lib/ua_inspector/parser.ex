defmodule UAInspector.Parser do
  @moduledoc """
  Parser module to call individual data parsers and aggregate the results.
  """

  use Behaviour

  alias UAInspector.Parser
  alias UAInspector.Result
  alias UAInspector.Util

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
    ua
    |> assemble_result()
    |> maybe_fix_android()
  end


  defp assemble_result(ua) do
    %Result{
      user_agent: ua,
      client:     Parser.Client.parse(ua),
      device:     Parser.Device.parse(ua),
      os:         Parser.OS.parse(ua)
    }
  end

  # Android <  2.0.0 is always a smartphone
  # Andoird == 3.*   is always a tablet
  defp maybe_fix_android(%{ os: %{ version: :unknown }} = result) do
    result
  end

  defp maybe_fix_android(%{ os:     %{ name: "Android" } = os,
                            device: %{ type: "desktop" }} = result) do
    version = Util.to_semver(os.version)
    type    =  cond do
      smartphone_android?(version) -> "smartphone"
      tablet_android?(version)     -> "tablet"
      true                         -> result.device.type
    end

    %{ result | device: %{ result.device | type: type }}
  end

  defp maybe_fix_android(result), do: result


  defp smartphone_android?(version) do
    :lt == Version.compare(version, "2.0.0")
  end

  defp tablet_android?(version) do
    :lt != Version.compare(version, "3.0.0")
    && :lt == Version.compare(version, "4.0.0")
  end
end
