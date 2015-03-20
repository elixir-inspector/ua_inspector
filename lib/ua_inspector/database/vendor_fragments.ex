defmodule UAInspector.Database.VendorFragments do
  @moduledoc """
  UAInspector vendor fragment information database.
  """

  use UAInspector.Database

  alias UAInspector.Util

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"

  @ets_counter :vendor_fragments
  @ets_table   :ua_inspector_vendor_fragments
  @sources [{ "", "vendorfragments.yml", "#{ @source_base_url }/vendorfragments.yml" }]

  def store_entry({ brand, regexes }, _type) do
    counter = UAInspector.Databases.update_counter(@ets_counter)
    regexes = regexes |> Enum.map( &Util.build_regex(&1) )

    entry   = %{
      brand:   brand,
      regexes: regexes
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
