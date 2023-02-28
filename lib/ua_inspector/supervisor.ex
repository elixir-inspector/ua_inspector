defmodule UAInspector.Supervisor do
  @moduledoc """
  This supervisor module takes care of starting the required database storage
  processes. It is automatically started with the `:ua_inspector` application.

  If you do not want to automatically start the application itself you can
  adapt your configuration for a more manual supervision approach.

  Instead of adding `:ua_inspector` to your `:applications` list or using
  the automatic discovery you need to add it to your `:included_applications`:

      def application do
        [
          included_applications: [
            # ...
            :ua_inspector,
            # ...
          ]
        ]
      end

  That done you can add `UAInspector.Supervisor` to your hierarchy:

      children = [
        # ...
        UAInspector.Supervisor,
        # ..
      ]
  """

  use Supervisor

  alias UAInspector.Config

  require Logger

  @doc false
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl Supervisor
  def init(_state) do
    :ok = Config.init_env()

    check_database_release()

    children = [
      UAInspector.ClientHints.Supervisor,
      UAInspector.Database.Supervisor,
      UAInspector.ShortCodeMap.Supervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp check_database_release do
    with false <- Config.get(:startup_silent, false),
         true <- Config.default_remote_database?(),
         release_file <- Path.join(Config.database_path(), "ua_inspector.release"),
         true <- File.exists?(release_file),
         {:ok, database_release} <- File.read(release_file),
         false <- Config.remote_release() == String.trim(database_release) do
      Logger.info(
        "Your local UAInspector database release #{inspect(String.trim(database_release))}" <>
          " differs from the current default release #{inspect(Config.remote_release())}." <>
          " Please update your database or delete the release tracking file" <>
          " located at #{inspect(release_file)}."
      )
    end
  end
end
