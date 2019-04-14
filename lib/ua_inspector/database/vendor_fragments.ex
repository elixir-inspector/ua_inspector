defmodule UAInspector.Database.VendorFragments do
  @moduledoc false

  use UAInspector.Database,
    ets_prefix: :ua_inspector_db_vendor_fragments

  alias UAInspector.Config
  alias UAInspector.Util

  def sources do
    [
      {"", "vendor_fragment.vendorfragments.yml",
       Config.database_url(:vendor_fragment, "vendorfragments.yml")}
    ]
  end

  def to_ets({brand, regexes}, _type) do
    regexes = regexes |> Enum.map(&Util.build_regex/1)

    %{
      brand: brand,
      regexes: regexes
    }
  end
end
