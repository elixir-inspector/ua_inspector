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

### Package Startup (application)

Probably the easiest way to manage startup is by simply adding `:ua_inspector` to the list of applications:

```elixir
def application do
  [
    applications: [
      # ...
      :ua_inspector,
      # ...
    ]
  ]
end
```

### Package Startup (manual supervision)

A second possible approach is to take care of supervision yourself. This means you should add `:ua_inspector` to your included applications instead:

```elixir
def application do
  [
    included_applications: [
      # ...
      :ua_inspector,
      # ...
    ]
  ]
end
```

And also add the appropriate `UAInspector.Supervisor` to your hierarchy:

```elixir
# in your application/supervisor
children = [
  # ...
  UAInspector.Supervisor,
  # ..
]
```

## Application Configuration

To start using UAInspector you need to at least configure a `:database_path`.

### Configuration (static)

One option for configuration is using a static configuration:

```elixir
config :ua_inspector,
  database_path: "/path/to/ua_inspector/databases"
```

### Configuration (dynamic)

If there are any reasons you cannot use a pre-defined configuration you can also configure an initializer module to be called before starting the application supervisor. The configuration is expected to consist of a `{mod, fun}` or `{mod, fun, args}` tuple and the function is expected to always return `:ok`.

This may be the most suitable configuration if you have the databases located in the `:priv_dir` of your application.

```elixir
# {mod, fun}
config :ua_inspector,
  init: {MyInitModule, :my_init_mf}

# {mod, fun, args}
config :ua_inspector,
  init: {MyInitModule, :my_init_mfa, [:foo, :bar]}

defmodule MyInitModule do
  @spec my_init_mf() :: :ok
  def my_init_mf(), do: my_init_mfa(:foo, :bar)

  @spec my_init_mfa(atom, atom) :: :ok
  def my_init_mfa(:foo, :bar) do
    priv_dir = Application.app_dir(:my_app, "priv")

    Application.put_env(:ua_inspector, :database_path, priv_dir)
  end
end
```

### Configuration (Database Files)

The base url of database files is configurable:

```elixir
remote_database = "https://raw.githubusercontent.com/matomo-org/device-detector/master/regexes"
remote_shortcode = "https://raw.githubusercontent.com/matomo-org/device-detector/master"

config :ua_inspector,
  remote_path: [
    bot: "#{remote_database}",
    browser_engine: "#{remote_database}/client",
    client: "#{remote_database}/client",
    device: "#{remote_database}/device",
    os: "#{remote_database}",
    short_code_map: "#{remote_shortcode}",
    vendor_fragment: "#{remote_database}"
  ]
```

Shown configuration is used as the default location during download.

For the time being the detailed path append to the remote path is not configurable. This is a major caveat for the short code mappings and subject to change.

#### Default Database Release Version

If you are using the default database the newest version from the `"master"` branch will be used. You can also configure a different release to be used:

```elixir
config :ua_inspector, remote_release: "v1.0.0"
```

This feature is only available for the default database configuration.

### Configuration (ETS Cleanup)

When reloading the old database is deleted with a configurable delay. The delay is defined in milliseconds with a default of `30_000`.

```elixir
config :ua_inspector,
  ets_cleanup_delay: 30_000
```

### Configuration (HTTP client)

The database is downloaded using [`:hackney`](https://github.com/benoitc/hackney). To pass custom configuration values to hackney you can use the key `:http_opts` in your config:

```elixir
config :ua_inspector,
  http_opts: [proxy: "http://mycompanyproxy.com"]
```

Please see [`:hackney.request/5`](https://hexdocs.pm/hackney/hackney.html#request-5) for a complete list of available options.

## Parser Databases

Using `mix ua_inspector.download` you can store local copies of the supported parser databases and short code maps in the configured path. The databases are taken from the [matomo-org/device-detector](https://github.com/matomo-org/device-detector) project.

The local path of the downloaded files will be shown to you upon command invocation.

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
