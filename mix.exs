defmodule UAInspector.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/ua_inspector"
  @url_github "https://github.com/elixytics/ua_inspector"

  def project do
    [ app:           :ua_inspector,
      name:          "UAInspector",
      description:   "User agent parser library",
      package:       package,
      version:       "0.8.0",
      elixir:        "~> 1.0",
      deps:          deps(Mix.env),
      docs:          docs,
      test_coverage: [ tool: ExCoveralls ]]
  end

  def application do
    [ applications: [ :yamerl ],
      mod:          { UAInspector, [] } ]
  end

  def deps(:docs) do
    deps(:prod) ++
      [ { :earmark, "~> 0.1", optional: true },
        { :ex_doc,  "~> 0.7", optional: true } ]
  end

  def deps(:test) do
    deps(:prod) ++
      [ { :dialyze,     "~> 0.2", optional: true },
        { :excoveralls, "~> 0.3", optional: true } ]
  end

  def deps(_) do
    [ { :poolboy, "~> 1.0" },
      { :yamerl,  github: "yakaz/yamerl" } ]
  end

  def docs do
    [ main:       "README",
      readme:     "README.md",
      source_ref: "v0.8.0",
      source_url: @url_github ]
  end

  def package do
    %{ contributors: [ "Marc Neudert", "Michael Shapiro" ],
       files:        [ "CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib" ],
       licenses:     [ "Apache 2.0" ],
       links:        %{ "Docs" => @url_docs, "Github" => @url_github }}
  end
end
