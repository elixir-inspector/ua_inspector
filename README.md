# ExAgent

User agent parser library.


## Configuration

To use ExAgent with your projects, edit your `mix.exs` file and add it as a
dependency:

```elixir
defp deps do
  [ { :ex_agent, github: "elixytics/ex_agent" } ]
end
```

Please note that yamler requires [libyaml](http://pyyaml.org/wiki/LibYAML)
(including development headers) to be present on your system.


## Usage

_Note: the information returned are not complete... yet._

```elixir
iex(1)> ExAgent.parse("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36")
[ string: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
  device: [ family: :unknown, version: :unknown ],
  os:     [ family: "linux",  version: :unknown ],
  ua:     [ family: "chrome", version: :unknown ] ]
```

_Device_, _os_ and _ua_ are dicts containing the elements _family_ and
_version_.

The values of the nested elements will strings if they are properly matched,
otherwise an atom with the value __:unknown__.

_String_ will return the passed user agent unmodified.


## Resources

- [ua-parser](https://github.com/tobie/ua-parser)
- [yamler](https://github.com/superbobry/yamler)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Regexes.yaml_ taken from the [ua-parser](https://github.com/tobie/ua-parser)
project. See there for detailed license information about the data contained.
