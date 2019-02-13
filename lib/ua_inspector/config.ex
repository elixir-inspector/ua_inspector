defmodule UAInspector.Config do
  @moduledoc """
  Utility module to simplify access to configuration values.
  """

  require Logger

  @remote_base "https://raw.githubusercontent.com/matomo-org/device-detector/"
  @remote_release "master"
  @remote_paths [
    bot: "/regexes",
    browser_engine: "/regexes/client",
    client: "/regexes/client",
    device: "/regexes/device",
    os: "/regexes",
    short_code_map: "",
    vendor_fragment: "/regexes"
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
  @spec database_path() :: String.t() | nil
  def database_path do
    case get(:database_path) do
      nil -> nil
      path -> Path.expand(path)
    end
  end

  @doc """
  Returns the remote url of a database file.
  """
  @spec database_url(atom, String.t()) :: String.t()
  def database_url(type, file) do
    file = String.replace_leading(file, "/", "")

    default = default_database_url(type)

    remote =
      [:remote_path, type]
      |> get(default)
      |> String.replace_trailing("/", "")

    remote <> "/" <> file
  end

  @doc """
  Returns whether the remote database (at least one type) matches the default.
  """
  @spec default_remote_database?() :: boolean
  def default_remote_database? do
    Enum.any?(Keyword.keys(@remote_paths), fn type ->
      default = default_database_url(type)

      get([:remote_path, type], default) == default
    end)
  end

  @doc """
  Calls the optionally configured init method.
  """
  @spec init_env() :: :ok
  def init_env do
    case get(:init) do
      nil -> :ok
      {mod, fun} -> apply(mod, fun, [])
    end
  end

  defp default_database_url(type) do
    if Keyword.has_key?(@remote_paths, type) do
      @remote_base <> get(:remote_release, @remote_release) <> @remote_paths[type]
    else
      ""
    end
  end

  defp log_system_config_deprecation do
    Logger.info(fn ->
      "Accessing the system environment for configuration via" <>
        " {:system, \"var\"} has been deprecated. Please switch" <>
        " to an initializer function to avoid future problems."
    end)
  end

  defp maybe_fetch_system(config) when is_list(config) do
    Enum.map(config, fn
      {k, v} -> {k, maybe_fetch_system(v)}
      other -> other
    end)
  end

  defp maybe_fetch_system({:system, var, default}) do
    _ = log_system_config_deprecation()
    System.get_env(var) || default
  end

  defp maybe_fetch_system({:system, var}) do
    _ = log_system_config_deprecation()
    System.get_env(var)
  end

  defp maybe_fetch_system(config), do: config

  defp maybe_use_default(nil, default), do: default
  defp maybe_use_default(config, _), do: config
end
