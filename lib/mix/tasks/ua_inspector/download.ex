defmodule Mix.Tasks.UaInspector.Download do
  @moduledoc """
  Mix task to download database file(s) from your command line.

  ## Arguments

  When run without arguments the task will display the target directory for the
  downloaded files and will ask for confirmation before downloading.

  - `--force`: skip confirmation before downloading
  - `--quiet`: silences task output (does not imply `--force`!)

  ## Informational README

  If you are using the default databases from the default remote location an
  informational README with the filename `ua_inspector.readme.md` will be
  placed next to the downloaded file(s). Inside you will find a link to the
  original database source.

  The creation of this file can be deactivated by configuration:

      config :ua_inspector,
        skip_download_readme: true

  ## Release Information

  If you are using the default databases from the default remote location an
  informational release file will be placed next to the downloaded file(s).
  Inside you will find the remote release version configured for the download.

  The creation of this file can be deactivated by configuration:

      config :ua_inspector,
        skip_download_release: true
  """

  @shortdoc "Downloads database files"

  alias UAInspector.Config
  alias UAInspector.Downloader

  use Mix.Task

  @cli_options [
    aliases: [f: :force],
    strict: [force: :boolean, quiet: :boolean]
  ]

  @impl Mix.Task
  def run(args) do
    :ok = load_app(args)
    :ok = Config.init_env()

    {opts, _argv, _errors} = OptionParser.parse(args, @cli_options)

    if !opts[:quiet] do
      Mix.shell().info("Download path: #{Config.database_path()}")
      Mix.shell().info("This command will replace any existing files!")
    end

    if request_confirmation(opts) do
      perform_download(opts)
    else
      exit_unconfirmed(opts)
    end
  end

  defp exit_unconfirmed(opts) do
    if !opts[:quiet] do
      Mix.shell().info("Download aborted!")
    end

    :ok
  end

  defp perform_download(opts) do
    :ok = Downloader.download(:client_hints)
    :ok = Downloader.download(:databases)
    :ok = Downloader.download(:short_code_maps)
    :ok = Downloader.README.write()
    :ok = Downloader.Release.write()

    if !opts[:quiet] do
      Mix.shell().info("Download complete!")
    end

    :ok
  end

  defp request_confirmation(opts) do
    case opts[:force] do
      true -> true
      _ -> Mix.shell().yes?("Download databases?")
    end
  end

  defp load_app(args) do
    _ = Mix.Task.run("loadpaths", args)

    if "--no-compile" not in args do
      _ = Mix.Task.run("compile", args)
    end

    :ok
  end
end
