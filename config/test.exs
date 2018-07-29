use Mix.Config

config :ua_inspector,
  database_path: Path.join(__DIR__, "../test/fixtures"),
  ets_cleanup_delay: 10,
  pool: [max_overflow: 0, size: 1]
