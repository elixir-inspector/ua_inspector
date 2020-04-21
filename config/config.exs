use Mix.Config

if Mix.env() == :bench do
  config :ua_inspector,
    database_path: Path.expand("../priv", __DIR__)
end

if Mix.env() == :test do
  config :ua_inspector,
    database_path: Path.expand("../test/fixtures", __DIR__)
end
