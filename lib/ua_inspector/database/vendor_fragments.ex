defmodule UAInspector.Database.VendorFragments do
  @moduledoc """
  UAInspector vendor fragment information database.
  """

  @ets_table       :ua_inspector_database_vendor_fragments
  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"

  use UAInspector.Database, [
    ets_table: @ets_table,
    sources:   [{ "", "vendorfragments.yml", "#{ @source_base_url }/vendorfragments.yml" }]
  ]

  alias UAInspector.Util

  def store_entry({ brand, regexes }, _type) do
    counter = UAInspector.Databases.update_counter(:vendor_fragments)
    regexes = regexes |> Enum.map( &Util.build_regex/1 )

    entry = %{
      brand:   brand,
      regexes: regexes
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
