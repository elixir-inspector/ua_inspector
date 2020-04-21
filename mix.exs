defmodule UAInspector.MixProject do
  use Mix.Project

  @url_github "https://github.com/elixir-inspector/ua_inspector"

  def project do
    [
      app: :ua_inspector,
      name: "UAInspector",
      version: "2.1.0-dev",
      elixir: "~> 1.7",
      aliases: aliases(),
      deps: deps(),
      description: "User agent parser library",
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        "bench.parse": :bench,
        "bench.parse_list": :bench,
        "bench.parse_client": :bench,
        "bench.parse_device": :bench,
        "bench.parse_os": :bench,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test
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
      "bench.parse_list": "run bench/parse_list.exs",
      "bench.parse_client": "run bench/parse_client.exs",
      "bench.parse_device": "run bench/parse_device.exs",
      "bench.parse_os": "run bench/parse_os.exs"
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :bench, runtime: false},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.12", only: :test, runtime: false},
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
      plt_add_apps: [:mix]
    ]
  end

  defp docs do
    [
      main: "UAInspector",
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
