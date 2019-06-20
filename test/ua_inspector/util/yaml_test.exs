defmodule UAInspector.Util.YAMLTest do
  use ExUnit.Case, async: false

  alias UAInspector.Util.YAML

  setup do
    yaml_file_reader = Application.get_env(:ua_inspector, :yaml_file_reader)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :yaml_file_reader, yaml_file_reader)
    end)
  end

  defmodule NoopYAML do
    def call_mf(_file), do: [:ok_mf]
    def call_mfa(_file, [:arg]), do: [:ok_mfa]
  end

  test "yaml file reader: {mod, fun}" do
    Application.put_env(:ua_inspector, :yaml_file_reader, {NoopYAML, :call_mf})

    assert {:ok, :ok_mf} = YAML.read_file(__ENV__.file)
  end

  test "yaml file reader: {mod, fun, extra_args}" do
    Application.put_env(:ua_inspector, :yaml_file_reader, {NoopYAML, :call_mfa, [[:arg]]})

    assert {:ok, :ok_mfa} = YAML.read_file(__ENV__.file)
  end
end
