defmodule Mix.ExAgent do
  def download_path(), do: Path.join(Mix.Utils.mix_home, "ex_agent")
end
