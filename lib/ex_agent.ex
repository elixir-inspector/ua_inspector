defmodule ExAgent do
  use Application

  def start(_, _) do
    ExAgent.Supervisor.start_link()

    if Application.get_env(:ex_agent, :database_path) do
      load(Application.get_env(:ex_agent, :database_path))
    end

    { :ok, self() }
  end

  @doc """
  Loads parser databases from given base path.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(path), do: ExAgent.Databases.load(path)

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: Map.t
  def parse(ua), do: ExAgent.Pool.parse(ua)
end
