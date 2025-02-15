# UAInspector

[![CI](https://github.com/elixir-inspector/ua_inspector/actions/workflows/ci.yml/badge.svg)](https://github.com/elixir-inspector/ua_inspector/actions/workflows/ci.yml)
[![Module Version](https://img.shields.io/hexpm/v/ua_inspector.svg)](https://hex.pm/packages/ua_inspector)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ua_inspector/)
[![Total Downloads](https://img.shields.io/hexpm/dt/ua_inspector.svg)](https://hex.pm/packages/ua_inspector)
[![License](https://img.shields.io/hexpm/l/ua_inspector.svg)](https://github.com/elixir-inspector/ua_inspector/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/elixir-inspector/ua_inspector.svg)](https://github.com/elixir-inspector/ua_inspector/commits/master)

User agent parser library.

## Package Setup

To use UAInspector with your projects, edit your `mix.exs` file and add the required dependencies:

```elixir
defp deps do
  [
    # ...
    {:ua_inspector, "~> 3.0"},
    # ...
  ]
end
```

If you want to use a manual supervision approach (without starting the application) please look at the inline documentation of `UAInspector.Supervisor`.

## Application Configuration

Out of the box the default database files will be stored in the `:priv_dir` of `:ua_inspector`. Both the database sources and path used can be changed.

For a detailed list of available configuration options please consult `UAInspector.Config`.

## Basic Usage

### Database Download

You need to obtain a copy of the configured databases by calling either `mix ua_inspector.download` from the command line or `UAInspector.Downloader.download/0` from within your application.

Refer to `UAInspector.Downloader` for more details.

### User Agent Parsing

```elixir
iex> UAInspector.parse("Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
%UAInspector.Result{
  client: %UAInspector.Result.Client{
    engine: "WebKit",
    engine_version: "537.51.1",
    name: "Mobile Safari",
    type: "browser",
    version: "7.0"
  },
  device: %UAInspector.Result.Device{
    brand: "Apple",
    model: "iPad",
    type: "tablet"
  },
  os: %UAInspector.Result.OS{
    name: "iOS",
    platform: :unknown,
    version: "7.0.4"
  },
  user_agent: "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
}

iex> UAInspector.parse("Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36")
%UAInspector.Result.Bot{
  category: "Search bot",
  name: "Googlebot",
  producer: %UAInspector.Result.BotProducer{
    name: "Google Inc.",
    url: "http://www.google.com"
  },
  url: "http://www.google.com/bot.html",
  user_agent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36"
}
```

Full documentation is available inline in the `UAInspector` module and at [https://hexdocs.pm/ua_inspector](https://hexdocs.pm/ua_inspector).

## Benchmark

Several (minimal) benchmark scripts are included. Please refer to the Mixfile or `mix help` output for their names.

## Resources

- [matomo-org/device-detector](https://github.com/matomo-org/device-detector)

## Copyright and License

Copyright (c) 2013 Marc Neudert

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

The parser databases are taken from the [matomo-org/device-detector](https://github.com/matomo-org/device-detector) project. See there for detailed license information about the data contained.
