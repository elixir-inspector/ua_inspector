defmodule UAInspector.Verification.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ua_inspector_verification,
      version: "0.0.1",
      elixir: "~> 1.3",
      deps: deps(),
      deps_path: "../deps",
      lockfile: "../mix.lock"
    ]
  end

  def application do
    [applications: [:ua_inspector]]
  end

  defp deps do
    [{:ua_inspector, path: "../"}]
  end
end
