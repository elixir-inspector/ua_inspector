defmodule Mix.UAInspector do
  @moduledoc """
  Mix utility module.
  """

  @doc """
  Returns the path where the database files are downloaded to.
  """
  @spec download_path() :: String.t
  def download_path(), do: Path.join(Mix.Utils.mix_home, "ua_inspector")
end
