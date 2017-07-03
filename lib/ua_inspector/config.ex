defmodule UAInspector.Config do
  @moduledoc """
  Utility module to simplify access to configuration values.
  """

  @remote_database  "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"
  @remote_shortcode "https://raw.githubusercontent.com/piwik/device-detector/master"
  @remote_defaults  [
    bot:             "#{ @remote_database}",
    browser_engine:  "#{ @remote_database }/client",
    client:          "#{ @remote_database }/client",
    device:          "#{ @remote_database }/device",
    os:              "#{ @remote_database }",
    short_code_map:  "#{ @remote_shortcode }",
    vendor_fragment: "#{ @remote_database }"
  ]


  @doc """
  Provides access to configuration values with optional environment lookup.
  """
  @spec get(atom | [atom], term) :: term
  def get(key, default \\ nil)

  def get(key, default) when is_atom(key) do
    :ua_inspector
    |> Application.get_env(key, default)
    |> maybe_fetch_system()
  end

  def get(keys, default) when is_list(keys) do
    :ua_inspector
    |> Application.get_all_env()
    |> Kernel.get_in(keys)
    |> maybe_use_default(default)
    |> maybe_fetch_system()
  end

  @doc """
  Returns the configured database path or `nil`.
  """
  @spec database_path :: String.t | nil
  def database_path do
    case get_maybe_priv_path(:database_path) do
      nil  -> nil
      path -> Path.expand(path)
    end
  end

  @doc """
  Returns the remote url of a database file.
  """
  @spec database_url(atom, String.t) :: String.t
  def database_url(type, file) do
    file   = String.replace_leading(file, "/", "")
    remote =
      [ :remote_path, type ]
      |> get(@remote_defaults[type])
      |> String.replace_trailing("/", "")

    "#{ remote }/#{ file }"
  end

  defp get_maybe_priv_path(key) do
    case get(key) do
      {:priv, app, path} -> :code.priv_dir(app) |> Path.join(path)
      path               -> path
    end
  end

  defp maybe_fetch_system(config) when is_list(config) do
    Enum.map config, fn
      { k, v } -> { k, maybe_fetch_system(v) }
      other    -> other
    end
  end

  defp maybe_fetch_system({ :system, var, default }) do
    System.get_env(var) || default
  end

  defp maybe_fetch_system({ :system, var }), do: System.get_env(var)
  defp maybe_fetch_system(config),           do: config

  defp maybe_use_default(nil,    default), do: default
  defp maybe_use_default(config, _),       do: config
end
