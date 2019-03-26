# UAInspector

User agent parser library.

## Package Setup

To use UAInspector with your projects, edit your `mix.exs` file and add the required dependencies:

```elixir
defp deps do
  [
    # ...
    {:ua_inspector, "~> 0.20"},
    # ...
  ]
end
```

If you want to use a manual supervision approach (without starting the application) please look at the inline documentation of `UAInspector.Supervisor`.

## Application Configuration

Out of the box the default database files will be stored in the `:priv_dir` of `:ua_inspector`. Both the database sources and path used can be changed.

For a detailed list of available configuration options please consult `UAInspector.Config`.

## Parser Databases

Using `mix ua_inspector.download` you can store local copies of the supported parser databases and short code maps in the configured path. The databases are taken from the [matomo-org/device-detector](https://github.com/matomo-org/device-detector) project.

The local path of the downloaded files will be shown to you upon command invocation.

As a default database path (if not configured otherwise) the result of `Application.app_dir(:ua_inspector, "priv")` will be used.

If you want to download the database files using your application you can directly call `UAInspector.Downloader.download/0`.

When using both the mix task and a default remote configuration for at least one type of database an informational README is placed next to the downloaded file(s). This behaviour can be deactivated by configuration:

```elixir
config :ua_inspector,
  skip_download_readme: true
```

## Usage

After downloading a copy of the parse databases you can start parsing user agents:

```elixir
iex(1)> UAInspector.parse("Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
%UAInspector.Result{
  user_agent: "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
  client: %UAInspector.Result.Client{
    engine: "WebKit",
    engine_version: "537.51.11",
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
}

iex(2)> UAInspector.parse("Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36")
%UAInspector.Result.Bot{
  user_agent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36",
  category: "Search bot",
  name: "Googlebot",
  producer: %UAInspector.Result.BotProducer{
    name: "Google Inc.",
    url: "http://www.google.com"
  },
  url: "http://www.google.com/bot.html"
}

iex(3)> UAInspector.parse("generic crawler agent")
%UAInspector.Result.Bot{
  user_agent: "generic crawler agent",
  name: "Generic Bot"
}

iex(4)> UAInspector.parse("--- undetectable ---")
%UAInspector.Result{
  user_agent: "--- undetectable ---",
  client: :unknown,
  device: %UAInspector.Result.Device{ type: "desktop" },
  os: :unknown
}
```

The map key `:_user_agent` will hold the unmodified passed user agent.

If the device type cannot be determined a "desktop" device type will be assumed (and returned). Both `:brand` and `:model` are set to `:unknown`.

When a bot agent is detected the result with be a `UAInspector.Result.Bot` struct instead of `UAInspector.Result`.

### Reloading

Sometimes (for example after downloading a new database set) it is required to reload the internal database. This can be done asynchronously:

```elixir
UAInspector.reload()
```

This process is handled in the background, so for some time the old data will be used for lookups.

If you need to check if the database is still empty or (at least partially!) loaded, you can use `UAInspector.ready?/0`. Please be aware that this method checks the current state and not what will happen after a (potentially running) reload is finished.

### Convenience Methods

To perform only a quick check if a user agents belongs to a bot:

```elixir
iex(1)> UAInspector.bot?("generic crawler agent")
true

iex(2)> UAInspector.bot?("Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36")
false
```

To parse the client information for a user without checking for bots:

```elixir
iex(1)> UAInspector.parse_client("generic crawler agent")
%UAInspector.Result{
  user_agent: "generic crawler agent"
  client: :unknown,
  device: :unknown,
  os: :unknown
}
```

## Benchmark

A (minimal) benchmark script is included:

```shell
mix bench.parse
```

## Resources

- [matomo-org/device-detector](https://github.com/matomo-org/device-detector)

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

The parser databases are taken from the [matomo-org/device-detector](https://github.com/matomo-org/device-detector) project. See there for detailed license information about the data contained.
