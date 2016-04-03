defmodule UAInspector.Mixfile do
  use Mix.Project

  @url_github "https://github.com/elixytics/ua_inspector"

  def project do
    [ app:     :ua_inspector,
      name:    "UAInspector",
      version: "0.12.0-dev",
      elixir:  "~> 1.0",
      deps:    deps,

      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      preferred_cli_env: [
        coveralls:          :test,
        'coveralls.detail': :test,
        'coveralls.travis': :test,
        dialyze:            :test,
        docs:               :docs,
        'hex.docs':         :docs
      ],

      description:   "User agent parser library",
      docs:          docs,
      package:       package,
      test_coverage: [ tool: ExCoveralls ] ]
  end

  def application do
    [ applications: [ :poolboy, :yamerl ],
      mod:          { UAInspector, [] } ]
  end

  defp deps do
    [ { :earmark, "~> 0.2",  only: :docs },
      { :ex_doc,  "~> 0.11", only: :docs },

      { :dialyze,     "~> 0.2", only: :test },
      { :excoveralls, "~> 0.5", only: :test },

      { :poolboy, "~> 1.0" },
      { :yamerl,  github: "yakaz/yamerl" } ]
  end

  defp docs do
    [ extras:     [ "CHANGELOG.md", "README.md" ],
      main:       "readme",
      source_ref: "master",
      source_url: @url_github ]
  end

  defp package do
    %{ files:       [ "CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib" ],
       licenses:    [ "Apache 2.0" ],
       links:       %{ "GitHub" => @url_github },
       maintainers: [ "Marc Neudert" ] }
  end
end
