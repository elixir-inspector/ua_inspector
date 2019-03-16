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
    Application.get_env(:ua_inspector, key, default)
  end

  def get(keys, default) when is_list(keys) do
    :ua_inspector
    |> Application.get_all_env()
    |> Kernel.get_in(keys)
    |> maybe_use_default(default)
  end

  @doc """
  Returns the configured database path.

  If the path is not defined the `priv` dir of `:ua_inspector`
  as returned by `Application.app_dir(:ua_inspector, "priv")` will be used.
  """
  @spec database_path() :: String.t()
  def database_path do
    case get(:database_path) do
      nil -> Application.app_dir(:ua_inspector, "priv")
      path -> path
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
      {mod, fun, args} -> apply(mod, fun, args)
    end
  end

  defp default_database_url(type) do
    if Keyword.has_key?(@remote_paths, type) do
      @remote_base <> get(:remote_release, @remote_release) <> @remote_paths[type]
    else
      ""
    end
  end

  defp maybe_use_default(nil, default), do: default
  defp maybe_use_default(config, _), do: config
end
