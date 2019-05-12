defmodule UAInspector.Verification.MixProject do
  use Mix.Project

  def project do
    [
      app: :ua_inspector_verification,
      version: "0.0.1",
      elixir: "~> 1.5",
      deps: [{:ua_inspector, path: "../"}],
      deps_path: "../deps",
      lockfile: "../mix.lock"
    ]
  end
end
