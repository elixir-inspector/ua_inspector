import Config

config :ua_inspector,
  database_path: Path.expand("../priv/database", __DIR__),
  http_opts: [protocols: [:http1]],
  startup_silent: true
