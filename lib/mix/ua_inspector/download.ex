defmodule Mix.UAInspector.Download do
  @moduledoc """
  Utility module to support download tasks.
  """

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
