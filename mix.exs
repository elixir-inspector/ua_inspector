defmodule UAInspector.MixProject do
  use Mix.Project

  @url_changelog "https://hexdocs.pm/ua_inspector/changelog.html"
  @url_github "https://github.com/elixir-inspector/ua_inspector"
  @version "3.0.1"

  def project do
    [
      app: :ua_inspector,
      name: "UAInspector",
      version: @version,
      elixir: "~> 1.9",
      aliases: aliases(),
      deps: deps(),
      description: "User agent parser library",
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        "bench.parse": :bench,
        "bench.parse_client": :bench,
        "bench.parse_device": :bench,
        "bench.parse_os": :bench,
        coveralls: :test,
        "coveralls.detail": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {UAInspector.Application, []}
    ]
  end

  defp aliases() do
    [
      "bench.parse": "run bench/parse.exs",
      "bench.parse_client": "run bench/parse_client.exs",
      "bench.parse_device": "run bench/parse_device.exs",
      "bench.parse_os": "run bench/parse_os.exs"
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :bench, runtime: false},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14.0", only: :test, runtime: false},
      {:hackney, "~> 1.0"},
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
      plt_add_apps: [:mix],
      plt_core_path: "plts",
      plt_file: {:no_warn, "plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      groups_for_modules: [
        "Database Downloader": [
          UAInspector.Downloader,
          UAInspector.Downloader.Adapter
        ],
        "Result Structs": [
          UAInspector.Result,
          UAInspector.Result.Bot,
          UAInspector.Result.BotProducer,
          UAInspector.Result.Client,
          UAInspector.Result.Device,
          UAInspector.Result.OS
        ]
      ],
      main: "UAInspector",
      source_url: @url_github,
      source_ref: "v#{@version}",
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      formatters: ["html"]
    ]
  end

  defp package do
    [
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib", "priv"],
      licenses: ["Apache-2.0"],
      links: %{
        "Changelog" => @url_changelog,
        "GitHub" => @url_github
      }
    ]
  end
end
