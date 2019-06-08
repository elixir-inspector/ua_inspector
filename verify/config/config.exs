use Mix.Config

config :ua_inspector,
  database_path: Path.expand("../databases", __DIR__),
  startup_sync: true
