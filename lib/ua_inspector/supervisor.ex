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

  @doc false
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl Supervisor
  def init(_state) do
    :ok = Config.init_env()

    children = [
      UAInspector.Database.Supervisor,
      UAInspector.ShortCodeMap.Supervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
