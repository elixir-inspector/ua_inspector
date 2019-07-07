defmodule UAInspector.Downloader.README do
  @moduledoc false

  require Logger

  alias UAInspector.Config

  @readme "ua_inspector.readme.md"

  @doc false
  @spec path_local() :: Path.t()
  def path_local do
    _ =
      Logger.info(
        "UAInspector.Downloader.README.path_local/0 has been" <>
          " declared internal and will eventually be removed."
      )

    Path.join(Config.database_path(), @readme)
  end

  @doc false
  @spec path_priv() :: Path.t()
  def path_priv do
    _ =
      Logger.info(
        "UAInspector.Downloader.README.path_priv/0 has been" <>
          " declared internal and will eventually be removed."
      )

    Application.app_dir(:ua_inspector, ["priv", @readme])
  end

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

    unless File.dir?(dirname_local) do
      File.mkdir_p!(dirname_local)
    end

    {:ok, _} = File.copy(path_priv, path_local)
    :ok
  end
end
