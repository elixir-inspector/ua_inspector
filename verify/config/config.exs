use Mix.Config

config :ua_inspector,
  database_path: Path.join(__DIR__, "../databases"),
  pool:          [ max_overflow: 0, size: 1 ]
