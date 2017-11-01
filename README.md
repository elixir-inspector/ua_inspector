# UA Inspector

User agent parser library.


## Setup

### Dependency

To use UA Inspector with your projects, edit your `mix.exs` file and add the
required dependencies:

```elixir
defp deps do
  [{ :ua_inspector, "~> 0.14" }]
end
```

### Application/Supervisor Setup

Probably the easiest way to manage startup is by simply
adding `:ua_inspector` to the list of applications:

```elixir
def application do
  [ applications: [ :ua_inspector ]]
end
```

A second possible approach is to take care of supervision yourself. This
means you should add `:ua_inspector` to your included applications instead:

```elixir
def application do
  [ included_applications: [ :ua_inspector ]]
end
```

And also add the appropriate `UAInspector.Supervisor` to your hierarchy:

```elixir
# in your application/supervisor
children = [
  # ...
  supervisor(UAInspector.Supervisor, [])
  # ..
]
```

### Parser Databases

Using `mix ua_inspector.download.databases` you can store local copies of the
supported parser databases in the configured path. The databases are taken from
the [piwik/device-detector](https://github.com/piwik/device-detector) project.

In addition to the parser databases you need to fetch the short code maps
using `mix ua_inspector.download.short_code_maps`. After conversion to yaml
files they are stored in the configured database directory.

The local path of the downloaded files will be shown to you upon command
invocation.

### Configuration

Add the path to the user agent database you want to use to your project
configuration:

```elixir
use Mix.Config

# static configuration
config :ua_inspector,
  database_path: Path.join(Mix.Utils.mix_home, "ua_inspector")

# system environment configuration
config :ua_inspector,
  database_path: { :system, "SOME_SYSTEM_ENV_VARIABLE" }

# system environment configuration with default
# (default will only be used if environment variable is UNSET)
config :ua_inspector,
  database_path: { :system, "SOME_SYSTEM_ENV_VARIABLE", "/custom/default" }
```

#### Configuration (Database Files)

The base url of database files is configurable:

```elixir
remote_database  = "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"
remote_shortcode = "https://raw.githubusercontent.com/piwik/device-detector/master"

config :ua_inspector,
  remote_path: [
    bot:             "#{ remote_database }",
    browser_engine:  "#{ remote_database }/client",
    client:          "#{ remote_database }/client",
    device:          "#{ remote_database }/device",
    os:              "#{ remote_database }",
    short_code_map:  "#{ remote_shortcode }",
    vendor_fragment: "#{ remote_database }"
  ]
```

Shown configuration is used as the default location during download.

For the time being the detailed path append to the remote path is not
configurable. This is a major caveat for the short code mappings and subject
to change.

#### Configuration (HTTP client)

The database is downloaded using
[`:hackney`](https://github.com/benoitc/hackney). To pass custom configuration
values to hackney you can use the key `:http_opts` in your config:

```elixir
config :ua_inspector,
  http_opts: [ proxy: "http://mycompanyproxy.com" ]
```

These values are expanded if using aforementioned `{ :system, "SOME_VAR" }`
(or `{ :system, "SOME_VAR", "default" }`) rule and then passed unmodified
to the client process.

Please see
[`:hackney.request/5`](https://hexdocs.pm/hackney/hackney.html#request-5)
for a complete list of available options.


## Usage

```elixir
iex(1)> UAInspector.parse("Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
%UAInspector.Result{
  user_agent: "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
  client: %UAInspector.Result.Client{
    engine:         "WebKit",
    engine_version: "537.51.11",
    name:           "Mobile Safari",
    type:           "browser",
    version:        "7.0"
  },
  device: %UAInspector.Result.Device{
    brand: "Apple",
    model: "iPad",
    type:  "tablet"
  },
  os: %UAInspector.Result.OS{
    name:     "iOS",
    platform: :unknown,
    version:  "7.0.4"
  },
}

iex(2)> UAInspector.parse("Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36")
%UAInspector.Result.Bot{
  user_agent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36",
  category:   "Search bot",
  name:       "Googlebot",
  producer: %UAInspector.Result.BotProducer{
    name: "Google Inc.",
    url:  "http://www.google.com"
  },
  url: "http://www.google.com/bot.html"
}

iex(3)> UAInspector.parse("generic crawler agent")
%UAInspector.Result.Bot{
  user_agent: "generic crawler agent",
  name:       "Generic Bot"
}

iex(4)> UAInspector.parse("--- undetectable ---")
%UAInspector.Result{
  user_agent: "--- undetectable ---",
  client:     :unknown,
  device:     %UAInspector.Result.Device{ type: "desktop" },
  os:         :unknown
}
```

The map key _user\_agent_ will hold the unmodified passed user agent.

If the device type cannot be determined a "desktop" `:type` will be
assumed (and returned). Both `:brand` and `:model` are set to `:unknown`.

When a bot agent is detected the result with be a `UAInspector.Result.Bot`
struct instead of `UAInspector.Result`.

### Convenience Methods

To perform only a quick check if a user agents belongs to a bot:

```elixir
iex(1)> UAInspector.bot? "generic crawler agent"
true

iex(2)> UAInspector.bot? "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36"
false
```

To parse the client information for a user without checking for bots:

```elixir
iex(1)> UAInspector.parse_client "generic crawler agent"
%UAInspector.Result{
  user_agent: "generic crawler agent"
  client:     :unknown,
  device:     :unknown,
  os:         :unknown
}
```


## Resources

- [piwik/device-detector](https://github.com/piwik/device-detector)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

The parser databases are taken from the
[piwik/device-detector](https://github.com/piwik/device-detector)
project. See there for detailed license information about the data contained.
