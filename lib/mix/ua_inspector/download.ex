defmodule Mix.UAInspector.Download do
  @moduledoc """
  Utility module to support download tasks.
  """

  alias Mix.UAInspector.README
  alias UAInspector.Config

  @doc """
  Prints an error because of missing configuration values.
  """
  @spec exit_unconfigured() :: no_return
  def exit_unconfigured() do
    Mix.shell().error("Database path not configured.")
    Mix.shell().error("See README.md for details.")
  end

  @doc """
  Prepares the local database path for downloads.
  """
  @spec prepare_database_path() :: :ok
  def prepare_database_path() do
    unless File.dir?(Config.database_path()) do
      File.mkdir_p!(Config.database_path())
    end

    README.write()
  end

  @doc """
  Reads a database file from its remote location.
  """
  @spec read_remote(String.t()) :: {:ok, term} | {:error, term}
  def read_remote(path) do
    {:ok, _} = Application.ensure_all_started(:hackney)

    http_opts = Application.get_env(:ua_inspector, :http_opts, [])
    {:ok, _, _, client} = :hackney.get(path, [], [], http_opts)

    :hackney.body(client)
  end

  @doc """
  Asks a user to confirm the download.

  To skip confirmation the argument `--force` can be passed to the mix task.
  """
  @spec request_confirmation(list) :: boolean
  def request_confirmation(args) do
    Mix.shell().info("Download path: #{Config.database_path()}")
    Mix.shell().info("This command will overwrite any existing files!")

    {opts, _argv, _errors} = OptionParser.parse(args, aliases: [f: :force])

    case opts[:force] do
      true -> true
      _ -> "Really download?" |> Mix.shell().yes?()
    end
  end
end
