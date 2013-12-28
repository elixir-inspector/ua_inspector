defmodule ExAgent.Mixfile do
  use Mix.Project

  def project do
    [ app:     :ex_agent,
      version: "0.0.1",
      elixir:  "~> 0.11.1",
      deps:    deps ]
  end

  def application do
    []
  end

  defp deps do
    [ { :httpotion, github: "myfreeweb/httpotion" },
      { :yamler,    github: "superbobry/yamler" } ]
  end
end
