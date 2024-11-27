defmodule UAInspector.Downloader.README do
  @moduledoc false

  alias UAInspector.Config

  @readme "ua_inspector.readme.md"

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
    path_local = Path.join(Config.database_path(), @readme)
    path_priv = Application.app_dir(:ua_inspector, ["priv", @readme])
    dirname_local = Path.dirname(path_local)

    if !File.dir?(dirname_local) do
      File.mkdir_p!(dirname_local)
    end

    _ =
      if path_priv != path_local do
        File.copy!(path_priv, path_local)
      end

    :ok
  end
end
