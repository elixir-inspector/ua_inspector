defmodule UAInspector.Config do
  @moduledoc """
  Module to simplify access to configuration values with default values.

  There should be no configuration required to start using `:ua_inspector` if
  you rely on the default values:

      remote_database = "https://raw.githubusercontent.com/matomo-org/device-detector/master/regexes"
      remote_shortcode = "https://raw.githubusercontent.com/matomo-org/device-detector/master"

      config :ua_inspector,
        database_path: Application.app_dir(:ua_inspector, "priv"),
        http_opts: [],
        remote_path: [
          bot: remote_database,
          browser_engine: remote_database <> "/client",
          client: remote_database <> "/client",
          device: remote_database <> "/device",
          os: remote_database,
          short_code_map: remote_shortcode,
          vendor_fragment: remote_database
        ],
        remote_release: "master",
        startup_silent: false,
        startup_sync: true,
        yaml_file_reader: {:yamerl_constr, :file, [[:str_node_as_binary]]}

  The default `:database_path` is evaluated at runtime and not compiled into
  a release!

  ## How to Configure

  There are two ways to change the configuration values with the preferred way
  depending on your environment and personal taste.

  ### Static Configuration

  If you can ensure the configuration are static and not dependent on i.e. the
  server your application is running on, you can use a static approach by
  modifying your `config.exs` file:

      config :ua_inspector,
        database_path: "/path/to/ua_inspector/databases"

  ### Dynamic Configuration

  If a compile time configuration is not possible or does not match the usual
  approach taken in your application you can use a runtime approach.

  This is done by defining an initializer module that will automatically be
  called by `UAInspector.Supervisor` upon startup/restart. The configuration
  is expected to consist of a `{mod, fun}` or `{mod, fun, args}` tuple:

      # {mod, fun}
      config :ua_inspector,
        init: {MyInitModule, :my_init_mf}

      # {mod, fun, args}
      config :ua_inspector,
        init: {MyInitModule, :my_init_mfargs, [:foo, :bar]}

      defmodule MyInitModule do
        @spec my_init_mf() :: :ok
        def my_init_mf(), do: my_init_mfargs(:foo, :bar)

        @spec my_init_mfargs(atom, atom) :: :ok
        def my_init_mfargs(:foo, :bar) do
          priv_dir = Application.app_dir(:my_app, "priv")

          Application.put_env(:ua_inspector, :database_path, priv_dir)
        end
      end

  The function is required to always return `:ok`.

  ## Startup Behaviour

  You can change this behaviour to have the application force an asynchronous
  database loading during the initial startup:

      config :ua_inspector,
        startup_sync: false

  This can lead to the first parsing calls to work with an empty database
  and therefore not return the results you expect.

  ### Starting Silently

  When starting the application you will receive warnings if the database is
  not available. If you want to hide these messages you can configure the
  startup the be completely silent:

      config :ua_inspector,
        startup_silent: true

  ## Database Configuration

  Configuring the database to use can be done using two related values:

  - `:database_path`
  - `:remote_path`

  The `:database_path` is the directory to look for when loading the databases.
  It is also the place where `UAInspector.Downloader` stores a downloaded copy.

  For the time being the detailed list of database files is not configurable.
  This is a major caveat for personal database copies and short code mappings
  (they have additional path information appended to the base). This behaviour
  is subject to change.

  The full configuration for remote paths contains the following values:

      config :ua_inspector
        remote_path: [
          bot: "http://example.com",
          browser_engine: "http://example.com",
          client: "http://example.com",
          device: "http://example.com",
          os: "http://example.com",
          short_code_map: "http://example.com",
          vendor_fragment: "http://example.com"
        ]

  ### Default Database Release Version

  If you are using the default database the newest version from the `"master"`
  branch will be used. You can also configure a different release to be used:

      config :ua_inspector,
        remote_release: "v1.0.0"

  ## Download Configuration

  Using the default configuration all download requests for your database files
  are done using [`:hackney`](https://hex.pm/packages/hackney). To pass custom
  configuration values to hackney you can use the key `:http_opts`:

      config :ua_inspector,
        http_opts: [proxy: "http://mycompanyproxy.com"]

  Please see
  [`:hackney.request/5`](https://hexdocs.pm/hackney/hackney.html#request-5)
  for a complete list of available options.

  If you want to change the library used to download the databases you can
  configure a module implementing the `UAInspector.Downloader.Adapter`
  behaviour:

      config :ua_inspector,
        downloader_adapter: MyDownloaderAdapter

  ## YAML File Reader Configuration

  By default the library [`:yamerl`](https://hex.pm/packages/yamerl) will
  be used to read and decode the YAML database files. You can configure this
  reader to be a custom module:

      config :ua_inspector,
        yaml_file_reader: {module, function}

      config :ua_inspector,
        yaml_file_reader: {module, function, extra_args}

  The configured module will receive the file to read as the first argument with
  any optionally configured extra arguments after that.
  """

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

  @default_downloader_adapter UAInspector.Downloader.Adapter.Hackney
  @default_yaml_reader {:yamerl_constr, :file, [[:str_node_as_binary]]}

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
  Returns the configured downloader adapter module.

  The modules is expected to adhere to the behaviour defined in
  `UAInspector.Downloader.Adapter`.
  """
  @spec downloader_adapter() :: module
  def downloader_adapter, do: get(:downloader_adapter, @default_downloader_adapter)

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

  @doc """
  Returns the `{mod, fun, extra_args}` to be used when reading a YAML file.
  """
  @spec yaml_file_reader :: {module, atom, [term]}
  def yaml_file_reader do
    case get(:yaml_file_reader) do
      {_, _, _} = mfargs -> mfargs
      {mod, fun} -> {mod, fun, []}
      _ -> @default_yaml_reader
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
