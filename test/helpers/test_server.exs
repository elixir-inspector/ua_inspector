defmodule ExAgent.TestHelper.TestServer do
  def start() do
    ExAgent.start_link()
    ExAgent.load_yaml(ExAgent.TestHelper.Regexes.yaml_fixture())
  end
end
