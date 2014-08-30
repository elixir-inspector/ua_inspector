defmodule ExAgent.Parser.Device do
  @moduledoc """
  ExAgent device information parser.
  """

  @doc """
  Parses device information from a user agent.

  Returns `:unknown` if no information is not found in the database.

      iex> parse("--- undetectable ---", [])
      :unknown
  """
  @spec parse(String.t, Enum.t) :: map

  def parse(_, []), do: :unknown

  def parse(ua, [ { _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_model(ua, entry, entry.models)
    else
      parse(ua, database)
    end
  end

  defp parse_model(ua, device, [ model | models ]) do
    if Regex.match?(model.regex, ua) do
      %{
        brand:  device.brand,
        device: model.device,
        model:  model.model
      }
    else
      parse_model(ua, device, models)
    end
  end
end
