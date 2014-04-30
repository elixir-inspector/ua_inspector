defmodule ExAgent.Mixfile do
  use Mix.Project

  def project do
    [ app:       :ex_agent,
      version:   "0.0.1",
      elixir:    "~> 0.13.1",
      deps:      deps,
      deps_path: "_deps" ]
  end

  def application, do: []

  defp deps do
    [ { :yamler, github: "superbobry/yamler" } ]
  end
end
