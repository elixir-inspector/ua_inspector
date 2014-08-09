defmodule Mix.ExAgent do
  def local_yaml(), do: Path.join(Mix.Utils.mix_home, "ex_agent/regexes.yaml")
end
