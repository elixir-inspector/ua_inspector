defmodule Mix.UAInspector.Download do
  @moduledoc """
  Utility module to support download tasks.
  """

  alias UAInspector.Config

  @readme_path       Path.join(__DIR__, "../files/README.md") |> Path.expand()
  @readme_content    @readme_path |> File.read!
  @external_resource @readme_path

  @doc """
  Prints an error because of missing configuration values.
  """
  @spec exit_unconfigured() :: no_return
  def exit_unconfigured() do
    Mix.shell.error "Database path not configured."
    Mix.shell.error "See README.md for details."
  end

  @doc """
  Prepares the local database path for downloads.
  """
  @spec prepare_database_path() :: :ok
  def prepare_database_path() do
    unless File.dir?(Config.database_path) do
      setup_database_path()
    end

    document_database_path()
  end

  @doc """
  Reads a database file from its remote location.
  """
  @spec read_remote(String.t) :: { :ok, term } | { :error, term }
  def read_remote(path) do
    { :ok, _ } = Application.ensure_all_started(:hackney)

    http_opts             = Application.get_env(:ua_inspector, :http_opts, [])
    { :ok, _, _, client } = :hackney.get(path, [], [], http_opts)

    :hackney.body(client)
  end

  @doc """
  Asks a user to confirm the download.

  To skip confirmation the argument `--force` can be passed to the mix task.
  """
  @spec request_confirmation(list) :: boolean
  def request_confirmation(args) do
    Mix.shell.info "Download path: #{ Config.database_path }"
    Mix.shell.info "This command will overwrite any existing files!"

    { opts, _argv, _errors } = OptionParser.parse(args, aliases: [ f: :force ])

    case opts[:force] do
      true -> true
      _    -> "Really download?" |> Mix.shell.yes?()
    end
  end


  # internal methods

  defp document_database_path() do
    readme_tgt = Path.join(Config.database_path, "README.md")

    File.write! readme_tgt, @readme_content

    :ok
  end

  defp setup_database_path() do
    Config.database_path |> File.mkdir_p!
  end
end
