import Config

config :ua_inspector,
  database_path: Path.expand("../databases", __DIR__),
  startup_silent: true,
  remote_release: "master"
