# ExAgent

User agent parser library.


## Setup

### Dependency

To use ExAgent with your projects, edit your `mix.exs` file and add it as a
dependency:

```elixir
defp deps do
  [ { :ex_agent, github: "elixytics/ex_agent" } ]
end
```

You should also update your applications to include all necessary projects:

```elixir
def application do
  [ applications: [ :ex_agent, :yamerl ] ]
end
```

### Parser Databases

Using `mix ex_agent.databases.download` you can store local copies of the
supported parser databases to your local MIX_HOME directory. The databases
are taken from the
[piwik/device-detector](https://github.com/piwik/device-detector) project.

The local path of the downloaded files will be shown to you upon command
invocation.

### Configuration

Add the path to the user agent database you want to use to your project
configuration:

```elixir
use Mix.Config

config :ex_agent,
  database_path: Path.join(Mix.Utils.mix_home, "ex_agent")
```

The shown path is the default download path used by the mix task.


## Usage

```elixir
iex(1)> ExAgent.parse("Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53")
%{
  string: "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
  client: %{
    name: "Mobile Safari",
    version: "7.0"
  },
  device: %{
    brand: "Apple",
    device: "tablet",
    model: "iPad"
  },
  os: %{
    name: "iOS",
    version: "7_0_4"
  },
}
iex(2)> ExAgent.parse("--- undetectable ---")
%{
  string: "--- undetectable ---",
  client: :unknown,
  device: :unknown,
  os:     :unknown
}
```

The map key _string_ will hold the unmodified passed user agent.


## Resources

- [piwik/device-detector](https://github.com/piwik/device-detector)
- [yamerl](https://github.com/yakaz/yamerl)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

The parser databases are taken from the
[piwik/device-detector](https://github.com/piwik/device-detector)
project. See there for detailed license information about the data contained.
