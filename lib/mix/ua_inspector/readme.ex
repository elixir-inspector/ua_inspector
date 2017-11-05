defmodule Mix.UAInspector.README do
  @moduledoc """
  Utility module to handle README.md in download folders.
  """

  alias UAInspector.Config

  @readme "README.md"

  @doc """
  Returns the path to the local copy of the README file.
  """
  @spec path :: Path.t()
  def path(), do: Path.join(Config.database_path(), @readme)

  @doc """
  Copies the README.md file to the download folder.
  """
  @spec write() :: :ok
  def write() do
    source = Path.join(:code.priv_dir(:ua_inspector), "README.md")
    target = path()

    {:ok, _} = File.copy(source, target)
    :ok
  end
end
