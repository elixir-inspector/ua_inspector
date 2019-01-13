defmodule Mix.Tasks.UaInspector.Download.ShortCodeMaps do
  @moduledoc false
  @shortdoc false

  alias Mix.UAInspector.Download
  alias UAInspector.Config
  alias UAInspector.Downloader

  use Mix.Task

  def run(args) do
    Mix.shell().info("The mix task you are using has been deprecated.")
    Mix.shell().info("Please use 'mix ua_inspector.download' in the future.")
    Mix.shell().info("The old task will cease to function in a future release.")
    Mix.shell().info("")

    Mix.shell().info("UAInspector Short Code Map Download")

    :ok = Config.init_env()

    case Config.database_path() do
      nil -> Download.exit_unconfigured()
      _ -> args |> Download.request_confirmation() |> run_confirmed()
    end
  end

  defp run_confirmed(false) do
    Mix.shell().info("Download aborted!")

    :ok
  end

  defp run_confirmed(true) do
    :ok = Downloader.download(:short_code_maps)

    Mix.shell().info("Download complete!")

    :ok
  end
end
