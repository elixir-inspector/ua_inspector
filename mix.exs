defmodule ExAgent.Mixfile do
  use Mix.Project

  def project do
    [ app:        :ex_agent,
      name:       "ExAgent",
      source_url: "https://github.com/elixytics/ex_agent",
      version:    "0.4.0",
      elixir:     "~> 1.0",
      deps:       deps(Mix.env),
      docs:       [ readme: true, main: "README" ] ]
  end

  def application do
    [ applications: [ :yamerl ],
      mod:          { ExAgent, [] } ]
  end

  def deps(:docs) do
    deps(:prod) ++
      [ { :earmark, "~> 0.1" },
        { :ex_doc,  "~> 0.6" } ]
  end

  def deps(_) do
    [ { :poolboy, "~> 1.0" },
      { :yamerl,  github: "yakaz/yamerl" } ]
  end
end
