defmodule Mix.UAInspector.README do
  @moduledoc """
  Utility module to handle README.md in download folders.
  """

  alias UAInspector.Config

  @readme "ua_inspector.readme.md"

  @doc """
  Returns the path to the local copy of the README file.
  """
  @spec path_local :: Path.t()
  def path_local(), do: Path.join(Config.database_path(), @readme)

  @doc """
  Returns the path of the README file distributed in priv_dir.
  """
  @spec path_priv :: Path.t()
  def path_priv(), do: Path.join(:code.priv_dir(:ua_inspector), @readme)

  @doc """
  Copies the README.md file to the download folder.
  """
  @spec write() :: :ok
  def write() do
    path_local = Path.dirname(path_local())

    unless File.dir?(path_local) do
      File.mkdir_p!(path_local)
    end

    {:ok, _} = File.copy(path_priv(), path_local())
    :ok
  end
end
