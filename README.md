# UA Inspector

User agent parser library.


## Setup

### Dependency

To use UA Inspector with your projects, edit your `mix.exs` file and add the
required dependencies:

```elixir
defp deps do
  [ { :ua_inspector, "~> 0.8" },
    { :yamerl,       github: "yakaz/yamerl" } ]
end
```

You should also update your applications to include all necessary projects:

```elixir
def application do
  [ applications: [ :ua_inspector ]]
end
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

config :ua_inspector,
  database_path: Path.join(Mix.Utils.mix_home, "ua_inspector")
```

The shown path is the default download path used by the mix task.


## Usage

```elixir
iex(1)> UAInspector.parse("Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
%UAInspector.Result{
  user_agent: "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
  client: %UAInspector.Result.Client{
    engine:  "WebKit",
    name:    "Mobile Safari",
    type:    "browser",
    version: "7.0"
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
iex(1)> UAInspector.bot? "generic crawler agent"
%UAInspector.Result{
  user_agent: "generic crawler agent"
  client:     :unknown,
  device:     %UAInspector.Result.Device{},
  os:         :unknown
}
```


## Testing

Some (mix task) tests may download files from the internet.
These tests are all tagged `:download` to allow skipping them.


## Resources

- [piwik/device-detector](https://github.com/piwik/device-detector)
- [yamerl](https://github.com/yakaz/yamerl)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

The parser databases are taken from the
[piwik/device-detector](https://github.com/piwik/device-detector)
project. See there for detailed license information about the data contained.
