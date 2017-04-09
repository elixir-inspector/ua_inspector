defmodule Mix.UAInspector.README do
  @moduledoc """
  Utility module to handle README.md in download folders.
  """

  @readme_path       Path.join(__DIR__, "../files/README.md") |> Path.expand()
  @readme_content    @readme_path |> File.read!
  @external_resource @readme_path

  @doc """
  Puts the UAInspector README.md into a folder.
  """
  @spec put(String.t) :: :ok
  def put(path) do
    readme_tgt = Path.join(path, "README.md")

    File.write! readme_tgt, @readme_content

    :ok
  end
end
