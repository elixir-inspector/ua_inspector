import Config

config :ua_inspector,
  database_path: Path.expand("../priv/database", __DIR__),
  startup_silent: true
