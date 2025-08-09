# Changelog

## v3.11.0-dev

- Enhancements
    - Added support to use "form factors" client hint header for improved detection
    - Default upstream database version is now `6.4.6`
    - Improved mobile app detection
    - Upstream improvements for OS platform detection have been integrated
    - Upstream improvements for Blink engine detection have been integrated
    - Upstream improvements for browser version detection have been integrated
    - Upstream improvements for library client detection have been integrated
    - Upstream improvements for Chromium version detection have been integrated
    - Upstream improvements for Windows version detection have been integrated
    - Upstream improvements for Linux client detection have been integrated
    - Upstream improvements for "Chrome OS" detection have been integrated
    - Upstream improvements for "Fire OS" detection have been integrated
    - Upstream improvements for "KaiOS" feature phone detection have been integrated
    - Upstream improvements for "LeafOS" detection have been integrated
    - Upstream improvements for "Meta Horizon" detection have been integrated
    - Upstream improvements for "Puffin" browser detection have been integrated
    - Upstream improvements for "TV-Browser Internet" detection have been integrated
    - Upstream improvements for "Wolvic" browser detection have been integrated
    - Upstream improvements for Android TV device detection have been integrated
    - Upstream improvements for TV device detection have been integrated

- Bug fixes
    - Fixed compilation for OTP 28+ ([#40](https://github.com/elixir-inspector/ua_inspector/pull/40))
    - Version parsing changed from "SemVer style" to "PHP style" for exact upstream compatibility

## v3.10.0 (2024-06-11)

- Enhancements
    - Default upstream database version is now `6.3.2`
    - Upstream improvements for "360 Secure" browser detection have been integrated
    - Upstream improvements for "Arachne" browser engine detection have been integrated
    - Upstream improvements for "Clecko" browser engine detection have been integrated
    - Upstream improvements for "Edge WebView" detection have been integrated
    - Upstream improvements for "LibWeb" browser engine detection have been integrated
    - Upstream improvements for "Lineage OS" detection have been integrated
    - Upstream improvements for "PICO OS" detection have been integrated
    - Upstream improvements for "QJY TV" browser detection have been integrated
    - Upstream improvements for "TV Bro" browser detection have been integrated
    - Upstream improvements for "SPARC64" platform detection have been integrated
    - Upstream improvements for Android mobile/tablet device detection have been integrated
    - Upstream improvements for OS platform detection have been integrated
    - Upstream improvements for wearable device detection have been integrated

- Bug fixes
    - Fix parsing if the fourth part of the user agent engine version (split by `.`) starts with `0[0-9]` ([#35](https://github.com/elixir-inspector/ua_inspector/issues/35))

## v3.9.0 (2024-02-20)

- Enhancements
    - Default upstream database version is now `6.3.0`
    - Upstream improvements for "Apple" brand detection have been integrated
    - Upstream improvements for "Chrome Android" smartphone detection have been integrated
    - Upstream improvements for "DuckDuckGo Privacy" browser detection have been integrated
    - Upstream improvements for "Iridium" browser detection have been integrated
    - Upstream improvements for "Vewd" browser detection have been integrated
    - Upstream improvements for TV device detection have been integrated

## v3.8.0 (2024-01-13)

- Enhancements
    - Default upstream database version is now `6.2.1`
    - Match upstream fake user agent device handling
    - Upstream improvements for Android application detection have been integrated
    - Upstream improvements for desktop device detection have been integrated
    - Upstream improvements for "Every Browser" detection have been integrated
    - Upstream improvements for "Fire OS" detection have been integrated
    - Upstream improvements for TV device detection have been integrated

## v3.7.0 (2023-11-18)

- Enhancements
    - Default upstream database version is now `6.2.0`
    - Upstream improvements for Blink engine version detection have been integrated
    - Upstream improvements for Android TV device detection have been integrated

## v3.6.0 (2023-10-09)

- Enhancements
    - Default upstream database version is now `6.1.6`
    - Upstream improvements for TV device detection have been integrated
    - Upstream improvements for wearable device detection have been integrated

## v3.5.0 (2023-08-22)

- Enhancements
    - Default upstream database version is now `6.1.5`
    - Special handling to detect the correct browser engine (and version) for a combination of a "Blink" style user agent and application client hint header has been integrated
    - Upstream improvements for TV device detection have been integrated

## v3.4.0 (2023-08-06)

- Enhancements
    - Default upstream database version is now `6.1.4`
    - Upstream improvements to detect device brand, if only model is found in client hints, have been integrated

## v3.3.1 (2023-06-06)

- Enhancements
    - Default upstream database version is now `6.1.3`

## v3.3.0 (2023-05-19)

- Enhancements
    - Default upstream database version is now `6.1.2`
    - Upstream improvements to handle fake user agents ("Android" + "Apple" combination) have been integrated

## v3.2.1 (2023-03-17)

- Enhancements
    - Default upstream database version is now `6.1.1`

## v3.2.0 (2023-03-04)

- Enhancements
    - Default upstream database version is now `6.1.0`
    - Upstream improvements to detect tablet devices have been integrated
    - Using the mix download task with a default database will save the `:remote_release` configured during download. If the version differs from the current default upon application startup, a `Logger.info/1` will be issued unless `startup_silent = true` is configured

## v3.1.1 (2023-02-20)

- Bug fixes
    - Devices containing `(lite) TV` in their agent are now properly identified as TV devices if more detailed information is not available

## v3.1.0 (2023-02-12)

- Enhancements
    - Allow checking if a user agent is a known desktop device using `UAInspector.desktop?/1`
    - Allow checking if a user agent is a known mobile device using `UAInspector.mobile?/1`
    - Default upstream database version is now `6.0.6`
    - Parser results can be passed directly to `UAInspector.bot?/1`, `UAInspector.hbbtv?/1`, and `UAInspector.shelltv?/1`
    - Added support to use client hint headers for improved detection
    - Upstream improvements to detect engine versions of "Blink" type browsers have been integrated
    - Upstream improvements to detect ShellTV devices have been integrated
    - Upstream improvements to detect x64 devices using Windows have been integrated
    - Upstream improvements to detect generic TV devices have been integrated

## v3.0.1 (2022-03-08)

- Enhancements
    - Default upstream database version is now `5.0.5`

## v3.0.0 (2022-03-06)

- Enhancements
    - Default upstream database version is now `5.0.4`
    - If a database or short code map contains no (zero) entries during startup/reload a `Logger.info/1` will be sent unless `startup_silent = true` is configured

- Backwards incompatible changes
    - Minimum required Elixir version is now `~> 1.9`
    - The (default) `:hackney` download adapter will now only accept responses with "200 OK". Depending on your environment it could be required to configure following redirects using `http_opts: [follow_redirect: true]`

## v2.2.0 (2020-10-29)

Default download database version has been pinned to "release 3.13.1" after major changes in the upstream sources ([matomo-org/device-detector](https://github.com/matomo-org/device-detector) moving towards a new major release).

There will be a new major version of `ua_inspector` with a rebuilt database support for `matomo-org/device-detector@v4.x` and/or a separate database built upon these sources to simplify future upgrades.

- Enhancements
    - Upstream improvements to detect engine versions of "Gecko" type browsers have been integrated

- Bug fixes
    - Brand names are now always returned as strings (as expected), even if parsed as numbers from the YAML database

## v2.1.0 (2020-08-17)

- Enhancements
    - New "desktop notebook" devices are detected
    - Upstream improvements to detect mobile apps using Chrome have been integrated

## v2.0.0 (2020-05-29)

- Enhancements
    - Detection will now make use of "browser families" to match upstream improvements for Chrome based devices
    - If detectable the "browser family" of a client is now available as `:browser_family` in the result struct
    - If detectable the "operating system family" of a client is now available as `:os_family` in the result struct

- Bug fixes
    - The mix download task should no longer start unnecessary applications ([#19](https://github.com/elixir-inspector/ua_inspector/issues/19))

- Backwards incompatible changes
    - Minimum required Elixir version is now `~> 1.7`
    - Several deprecated functions have been removed completely:
        - `UAInspector.Downloader.prepare_database_path/0`
        - `UAInspector.Downloader.read_remote/0`
        - `UAInspector.Downloader.README.path_local/0`
        - `UAInspector.Downloader.README.path_priv/0`
    - Startup is now done with a blocking database load by default

## v1.2.0 (2019-08-10)

- Enhancements
    - Warnings when starting without a database available can be silenced

- Bug fixes
    - The mix download task now works properly with initializer modules ([#18](https://github.com/elixir-inspector/ua_inspector/issues/18))

## v1.1.0 (2019-07-13)

- Enhancements
    - Configuring `startup_sync: true` allows you to ensure a synchronous database load is attempted before allowing to parse user agents
    - Database entries are now stored in a single named table instead of using an intermediate reference table
    - Output of mix task `ua_inspector.download` can be prevented by passing `--quiet` upon invocation. This does NOT imply `--force` and will still ask for confirmation
    - Passing `async: false` to `UAInspector.reload/1` allows you to block your calling process until the reload has finished
    - The library used to download the database files can be changed by configuring a module implementing the `UAInspector.Downloader.Adapter` behaviour
    - The library used to read YAML files can be changed by using the `:yaml_file_reader` configuration

- Bug fixes
    - Matching the documentation the informational README file created by the downloader will now only be created when using the mix task

- Deprecations
    - Several functions are now declared internal and will result in a `Logger.info/1` message when called until they will be eventually removed:
        - `UAInspector.Downloader.prepare_database_path/0`
        - `UAInspector.Downloader.read_remote/0`
        - `UAInspector.Downloader.README.path_local/0`
        - `UAInspector.Downloader.README.path_priv/0`

## v1.0.0 (2019-04-20)

- Ownership has been transferred to the [`elixir-inspector`](https://github.com/elixir-inspector) organisation

- Enhancements
    - Documentation is now available inline (`@moduledoc`, ...) with the `README.md` file targeting the repository (development) instead of releases
    - The default database path has been set to `Application.app_dir(:ua_inspector, "priv")`

- Backwards incompatible changes
    - Internal parser process pooling has been removed. If you require pooling you need to manually wrap `UAInspector.parse/1` (and related functions)
    - Minimum required Elixir version is now `~> 1.5`
    - Support for `{:system, var}` configuration has been removed
    - The deprecated mix tasks `ua_inspector.download.databases` and `ua_inspector.download.short_code_maps` have been removed

## v0.20.0 (2019-03-10)

- Enhancements
    - Initializer modules can be defined with additional arguments by using `{mod, fun, args}`
    - When using the default database you can now set a `:remote_release` to be used for downloading. The default is `"master"` but any valid commit from the upstream source is allowed

- Deprecations
    - Accessing the system environment by configuring `{:system, var}` or `{:system, var, default}` will now result in a `Logger.info/1` message and will stop working in a future release
    - The download tasks `ua_inspector.download.databases` and `ua_inspector.download.short_code_maps` are now deprecated and will be removed in a future release

## v0.19.2 (2019-02-12)

- Bug fixes
    - Short code maps are now stored in the correct file encoding (`UTF-8`) to allow parsing short code maps with characters like umlauts ([#15](https://github.com/elixir-inspector/ua_inspector/issues/15))

## v0.19.1 (2019-01-05)

- Enhancements
    - The (soft) deprecated download tasks `ua_inspector.download.databases` and `ua_inspector.download.short_code_maps` are no longer displayed in the output of `mix help`

## v0.19.0 (2019-01-03)

- Enhancements
    - All database files (parser databases and short code maps) can be downloaded using a single mix task `ua_inspector.download`
    - Downloading the databases ensures hackney is started to allow calling `mix run --no-start -e "UAInspector.Downloader.download()"`
    - Finding the data table is now done via a named lookup table instead of calling the database state server
    - If you need to check if all databases are loaded (i.e. "no longer empty") you can use `UAInspector.ready?/0`
    - OS Families are no longer hardcoded inside `Util.OS` but read from the original source and stored in a short code map
    - OS Families used for desktop detection are no longer hardcoded inside `Util.OS` but read from the original source and stored in a short code map
    - Reloading will now issue a warning if no database path is configured while resuming operation with an empty database

- Soft deprecations (no warnings)
    - The individual download tasks for databases and short code maps have been removed from the documentation. They are still completely functional but will eventually be removed after a proper deprecation phase

## v0.18.0 (2018-08-15)

- Enhancements
    - Configuration can be done on supervisor (re-) start or when running the mix download tasks by setting a `{mod, fun}` tuple for the config key `:init`. This method will be called without arguments.
    - Old data tables are deleted with a configurable delay after reloading to avoid race conditions (and the resulting empty lookup responses)

- Bug fixes
    - ETS tables of short code maps are now properly cleaned after reload

- Soft deprecations (no warnings)
    - Support for `{:system, "ENV_VARIABLE"}` configuration has been removed from the documentation. It will eventually be removed completely after a proper deprecation phase

## v0.17.0 (2018-02-18)

- Enhancements
    - References to `piwik` (like database URLs) have been updated to reflect the rename to `matomo`

## v0.16.1 (2018-01-17)

- Bug fixes
    - Broken module naming for the mix download tasks has been fixed ([#12](https://github.com/elixir-inspector/ua_inspector/issues/12))

## v0.16.0 (2018-01-05)

- Backwards incompatible changes
    - Minimum required Elixir version is now `~> 1.3`

## v0.15.1 (2018-01-17)

- Bug fixes
    - Broken module naming for the mix download tasks has been fixed ([#12](https://github.com/elixir-inspector/ua_inspector/issues/12))

## v0.15.0 (2017-12-30)

- Enhancements
    - All databases can be reloaded (asynchronously) using `UAInspector.reload/0`
    - Supervision can now be done without starting the application ([#8](https://github.com/elixir-inspector/ua_inspector/pulls/8))
    - The database downloader has been promoted to a directly usable module

- Bug fixes
    - If a device has no type configured in the database previously `nil` was returned instead of the expected `:unknown`

## v0.14.0 (2017-05-31)

- Enhancements
    - Empty user agents (`""` or `nil`) now return a result without performing an actual lookup. By definition an empty user agent is never detected as a bot
    - System environment configuration can set an optional default value to be used if the environment variable is unset

- Bug fixes
    - Properly handles `nil` values passed to the lookup functions ([#7](https://github.com/elixir-inspector/ua_inspector/issues/7))

## v0.13.0 (2016-09-08)

- Enhancements
    - Engine versions are extracted
    - Remote url of database files is now configurable. Due to naming changes a complete re-download is necessary
    - Remote url of short code map files is now configurable

## v0.12.0 (2016-08-18)

- Enhancements
    - Database downloads are done using hackney in order to prepare an upcoming auto-update feature
    - If the initial load of a database (during process initialisation) fails a message will be sent through `Logger.info/1`
    - If the initial load of a short code map (during process initialisation) fails a message will be sent through `Logger.info/1`

- Backwards incompatible changes
    - Completely unknown devices now yield `:unknown` instead of a struct with all values set to `:unknown`
    - Downloads are now done using `:hackney` instead of `mix`. This may force you to manually reconfigure the client
    - Minimum required Elixir version is now `~> 1.2`
    - Minimum required Erlang version is now `~> 18.0`

## v0.11.1 (2016-04-02)

- Bug fixes
    - Properly handles short code map files after upstream changes

## v0.11.0 (2016-03-28)

- Enhancements
    - Databases are reloaded if a storage process gets restarted
    - HbbTV version can be fetched using `hbbtv?/1`
    - Path can be configured by accessing the system environment ([#5](https://github.com/elixir-inspector/ua_inspector/pull/5))
    - Short code mappings are reloaded if a storage process gets restarted

## v0.10.0 (2015-11-10)

- Bug fixes
    - Fixes problems with mix tasks under case insensitive file systems

## v0.9.0 (2015-10-17)

- Enhancements
    - Convenience method to check if user agent belongs to a bot (`bot?/1`)
    - Convenience method to parse without checking for bots (`parse_client/1`)
    - Operating system platform included in result

## v0.8.0 (2015-07-09)

- Enhancements
    - Bots are included in the detection
    - Short code mappings are fetched and parsed on demand

- Backwards incompatible changes
    - Short code maps are no longer included in the repository
    - Renamed mix task `databases.download` to `download.databases`

## v0.7.0 (2015-05-31)

- Enhancements
    - Dependencies not used in production builds are marked as optional
    - Displays expanded download path for `mix ua_inspector.databases.download`
    - Verification script now automatically downloads database files
    - Worker pool options are no longer defined at compile time

- Backwards incompatible changes
    - Pool configuration is now expected to be a `Keyword.t`

## v0.6.0 (2015-04-06)

- Initial Release
