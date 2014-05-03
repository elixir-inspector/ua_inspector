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


## Usage

```elixir
iex(1)> ExAgent.parse("Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3")
%ExAgent.Response{
  string: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
  device: %ExAgent.Response.Device{
    family: "iPhone;"
  },
  os: %ExAgent.Response.OS{
    family: "iOS", major: "5",
    minor:  "1",   patch: "1", patch_minor: :unknown
  },
  ua: %ExAgent.Response.UA{
    family: "iPhone", major: "5",
    minor:  "1",      patch: :unknown
  }
}
```

_Device_, _os_ and _ua_ are structs containing the element _family_ and, if
available, several version indicators named _major_, _minor_, _patch_ and/or
_patch\_minor_.

The values of the nested elements will be strings if they are properly matched,
otherwise an atom with the value __:unknown__.

_String_ will return the passed user agent unmodified.


## Resources

- [ua-parser](https://github.com/tobie/ua-parser)
- [yamerl](https://github.com/yakaz/yamerl)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Regexes.yaml_ taken from the [ua-parser](https://github.com/tobie/ua-parser)
project. See there for detailed license information about the data contained.
