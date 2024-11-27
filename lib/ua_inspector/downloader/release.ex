defmodule UAInspector.Downloader.Release do
  @moduledoc false

  alias UAInspector.Config

  @release "ua_inspector.release"

  @doc """
  Writes the release information file if remote database is the default.
  """
  @spec write() :: :ok
  def write do
    default? = Config.default_remote_database?()
    release? = !Config.get(:skip_download_release)

    if default? && release? do
      do_write()
    else
      :ok
    end
  end

  defp do_write do
    path_local = Path.join(Config.database_path(), @release)
    dirname_local = Path.dirname(path_local)

    if !File.dir?(dirname_local) do
      File.mkdir_p!(dirname_local)
    end

    File.write!(path_local, Config.remote_release())
  end
end
