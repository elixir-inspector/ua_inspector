defmodule UAInspector.Verify.MixProject do
  use Mix.Project

  def project do
    [
      app: :ua_inspector_verify,
      version: "0.0.1",
      elixir: "~> 1.9",
      deps: [{:ua_inspector, path: "../"}],
      deps_path: "../deps",
      lockfile: "../mix.lock"
    ]
  end
end
