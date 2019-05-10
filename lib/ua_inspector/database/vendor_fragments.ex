defmodule UAInspector.Database.VendorFragments do
  @moduledoc false

  use UAInspector.Database

  alias UAInspector.Config
  alias UAInspector.Util

  def sources do
    [
      {"", "vendor_fragment.vendorfragments.yml",
       Config.database_url(:vendor_fragment, "vendorfragments.yml")}
    ]
  end

  def to_ets({brand, regexes}, _type) do
    %{
      brand: brand,
      regexes: Enum.map(regexes, &Util.build_regex/1)
    }
  end
end
