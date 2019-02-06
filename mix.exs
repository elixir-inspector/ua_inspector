defmodule UAInspector.Mixfile do
  use Mix.Project

  @url_github "https://github.com/elixytics/ua_inspector"

  def project do
    [
      app: :ua_inspector,
      name: "UAInspector",
      version: "0.20.0-dev",
      elixir: "~> 1.3",
      aliases: aliases(),
      deps: deps(),
      description: "User agent parser library",
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        "bench.parse": :bench,
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

  defp aliases() do
    [
      "bench.parse": [
        "ua_inspector.download --force",
        "run bench/parse.exs"
      ]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 0.11.0", only: :bench, runtime: false},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.9", only: :test, runtime: false},
      {:hackney, "~> 1.0"},
      {:poolboy, "~> 1.0"},
      {:yamerl, "~> 0.7"}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :race_conditions,
        :underspecs,
        :unmatched_returns
      ],
      plt_add_apps: [:mix]
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
