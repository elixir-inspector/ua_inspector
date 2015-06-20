defmodule Mix.UAInspector.Download do
  @moduledoc """
  Utility module to support download tasks.
  """

  alias UAInspector.Config

  @doc """
  Prepares the local database path for downloads.
  """
  @spec prepare_database_path() :: :ok
  def prepare_database_path() do
    case File.dir?(Config.database_path) do
      true  -> document_database_path()
      false -> setup_database_path()
    end
  end


  defp document_database_path() do
    readme_src = Path.join(__DIR__, "../files/README.md")
    readme_tgt = Path.join(Config.database_path, "README.md")

    File.copy! readme_src, readme_tgt

    :ok
  end

  defp setup_database_path() do
    Config.database_path |> File.mkdir_p!

    document_database_path()
  end
end
