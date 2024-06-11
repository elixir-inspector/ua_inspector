defmodule UAInspector.MixProject do
  use Mix.Project

  @url_changelog "https://hexdocs.pm/ua_inspector/changelog.html"
  @url_github "https://github.com/elixir-inspector/ua_inspector"
  @version "3.11.0-dev"

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
      extra_applications: extra_applications(Mix.env()) ++ [:logger],
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
      {:benchee, "~> 1.3", only: :bench, runtime: false},
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.16.0", only: :test, runtime: false},
      {:hackney, "~> 1.0"},
      {:yamerl, "~> 0.7"}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :underspecs,
        :unmatched_returns
      ],
      plt_add_apps: [:mix],
      plt_core_path: "plts",
      plt_local_path: "plts"
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

  defp extra_applications(:test), do: [:inets]
  defp extra_applications(_), do: []

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
