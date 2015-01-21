use Mix.Config

config :ua_inspector,
  database_path:     Path.join(__DIR__, "../test/fixtures"),
  pool_max_overflow: 0,
  pool_size:         1
