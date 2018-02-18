defmodule UAInspector.Mixfile do
  use Mix.Project

  @url_github "https://github.com/elixytics/ua_inspector"

  def project do
    [
      app: :ua_inspector,
      name: "UAInspector",
      version: "0.18.0-dev",
      elixir: "~> 1.3",
      deps: deps(),
      description: "User agent parser library",
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      applications: [:hackney, :logger, :poolboy, :yamerl],
      mod: {UAInspector.App, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.8", only: :test},
      {:hackney, "~> 1.0"},
      {:poolboy, "~> 1.0"},
      {:yamerl, "~> 0.6"}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      source_ref: "master",
      source_url: @url_github
    ]
  end

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib", "priv"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @url_github},
      maintainers: ["Marc Neudert"]
    }
  end
end
