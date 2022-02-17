import Config

if Mix.env() == :bench do
  config :ua_inspector,
    database_path: Path.expand("../data", __DIR__)
end

if Mix.env() == :test do
  config :ua_inspector,
    database_path: Path.expand("../test/fixtures/database", __DIR__),
    startup_silent: true
end
