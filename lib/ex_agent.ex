defmodule ExAgent do
  use Application

  def start(_, _) do
    ExAgent.Supervisor.start_link()

    if Application.get_env(:ex_agent, :yaml) do
      load_yaml(Application.get_env(:ex_agent, :yaml))
    end

    { :ok, self() }
  end

  @doc """
  Loads yaml file with user agent definitions.
  """
  @spec load_yaml(String.t) :: :ok | { :error, String.t }
  def load_yaml(file), do: GenServer.call(:ex_agent, { :load_yaml, file })

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: ExAgent.Response.t
  def parse(ua), do: GenServer.call(:ex_agent, { :parse, ua })
end
