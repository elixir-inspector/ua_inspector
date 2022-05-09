defmodule UAInspector.ClientHints.Apps do
  @moduledoc false

  alias UAInspector.Config

  @doc """
  Returns the local and remote sources for this database.
  """
  @callback source() :: {binary, binary}
  def source do
    {"client_hints.apps.yml",
     Config.database_url(:client_hints, "/apps.yml")}
  end
end
