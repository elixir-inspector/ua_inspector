use Mix.Config

if Mix.env() == :bench do
  config :ua_inspector, database_path: Path.join(__DIR__, "../data")
end

if Mix.env() == :test do
  config :ua_inspector,
    database_path: Path.join(__DIR__, "../test/fixtures"),
    ets_cleanup_delay: 10,
    pool: [max_overflow: 0, size: 1]
end
