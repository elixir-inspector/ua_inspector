defmodule UAInspector.Downloader.README do
  @moduledoc false

  alias UAInspector.Config

  @readme "ua_inspector.readme.md"

  @doc """
  Returns the path to the local copy of the README file.
  """
  @spec path_local() :: Path.t()
  def path_local, do: Path.join(Config.database_path(), @readme)

  @doc """
  Returns the path of the README file distributed in priv_dir.
  """
  @spec path_priv() :: Path.t()
  def path_priv, do: Application.app_dir(:ua_inspector, ["priv", @readme])

  @doc """
  Writes the informational README file if remote database is the default.
  """
  @spec write() :: :ok
  def write do
    default? = Config.default_remote_database?()
    readme? = !Config.get(:skip_download_readme)

    if default? && readme? do
      do_write()
    else
      :ok
    end
  end

  defp do_write do
    dirname_local = Path.dirname(path_local())

    unless File.dir?(dirname_local) do
      File.mkdir_p!(dirname_local)
    end

    {:ok, _} = File.copy(path_priv(), path_local())
    :ok
  end
end
