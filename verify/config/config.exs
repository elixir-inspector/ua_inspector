use Mix.Config

config :ua_inspector,
  database_path: Path.expand("../databases", __DIR__),
  pool: [max_overflow: 5, size: 10]
