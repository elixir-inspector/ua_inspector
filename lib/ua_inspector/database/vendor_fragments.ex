defmodule UAInspector.Database.VendorFragments do
  @moduledoc """
  UAInspector vendor fragment information database.
  """

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"

  use UAInspector.Database, [
    sources: [{ "", "vendorfragments.yml", "#{ @source_base_url }/vendorfragments.yml" }]
  ]

  alias UAInspector.Util

  def to_ets({ brand, regexes }, _type) do
    regexes = regexes |> Enum.map( &Util.build_regex/1 )

    %{
      brand:   brand,
      regexes: regexes
    }
  end
end
