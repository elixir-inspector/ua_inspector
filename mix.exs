defmodule ExAgent.Mixfile do
  use Mix.Project

  def project do
    [ app:        :ex_agent,
      name:       "ExAgent",
      source_url: "https://github.com/elixytics/ex_agent",
      version:    "0.1.0",
      elixir:     "~> 0.14.0",
      deps:       deps(Mix.env),
      deps_path:  "_deps",
      docs:       &docs/0 ]
  end

  def application do
    [ applications: [ :yamerl ],
      mod:          { ExAgent, [] } ]
  end

  defp deps(:docs) do
    deps(:prod) ++
      [ { :ex_doc, github: "elixir-lang/ex_doc", tag: "6ef80510e5037e3cbcc9bb96bc30daa441e74722" } ]
  end

  defp deps(_) do
    [ { :yamerl, github: "yakaz/yamerl" } ]
  end

  defp docs do
    [ readme:     true,
      main:       "README",
      source_ref: System.cmd("git rev-parse --verify --quiet HEAD") ]
  end
end
