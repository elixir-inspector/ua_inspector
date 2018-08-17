# Changelog

## v0.19.0-dev

- Enhancements
    - Finding the data table is now done via a named lookup table instead
      of calling the database state server

## v0.18.0 (2018-08-15)

- Enhancements
    - Configuration can be done on supervisor (re-) start or when running the
      mix download tasks by setting a `{ mod, fun }` tuple for the config key
      `:init`. This method will be called without arguments.
    - Old data tables are deleted with a configurable delay after reloading
      to avoid race conditions (and the resulting empty lookup responses)

- Bug fixes
    - ETS tables of short code maps are now properly cleaned after reload

- Soft deprecations (no warnings)
    - Support for `{ :system, "ENV_VARIABLE" }` configuration has been
      removed from the documentation. It will eventually be removed completely
      after a proper deprecation phase

## v0.17.0 (2018-02-18)

- Enhancements
    - References to `piwik` (like database URLs) have been updated to reflect
      the rename to `matomo`

## v0.16.1 (2018-01-17)

- Bug fixes
    - Broken module naming for the mix download tasks has been fixed
      ([#12](https://github.com/elixytics/ua_inspector/issues/12))

## v0.16.0 (2018-01-05)

- Backwards incompatible changes
    - Minimum required elixir version is now "~> 1.3"

## v0.15.1 (2018-01-17)

- Bug fixes
    - Broken module naming for the mix download tasks has been fixed
      ([#12](https://github.com/elixytics/ua_inspector/issues/12))

## v0.15.0 (2017-12-30)

- Enhancements
    - All databases can be reloaded (asynchronously) using
      `UAInspector.reload/0`
    - Supervision can now be done without starting the application
      ([#8](https://github.com/elixytics/ua_inspector/pulls/8))
    - The database downloader has been promoted to a directly usable module

- Bug fixes
    - If a device has no type configured in the database previously `nil` was
      returned instead of the expected `:unknown`

## v0.14.0 (2017-05-31)

- Enhancements
    - Empty user agents (`""` or `nil`) now return a result without performing
      an actual lookup. By definition an empty user agent is never detected
      as a bot
    - System environment configuration can set an optional default value
      to be used if the environment variable is unset

- Bug fixes
    - Properly handles `nil` values passed to the lookup functions
      ([#7](https://github.com/elixytics/ua_inspector/issues/7))

## v0.13.0 (2016-09-08)

- Enhancements
    - Engine versions are extracted
    - Remote url of database files is now configurable. Due to naming changes
      a complete re-download is necessary
    - Remote url of short code map files is now configurable

## v0.12.0 (2016-08-18)

- Enhancements
    - Database downloads are done using hackney in order to prepare an
      upcoming auto-update feature
    - If the initial load of a database (during process initialisiation)
      fails a message will be sent through `Logger.info/1`
    - If the initial load of a short code map (during process initialisation)
      fails a message will be sent through `Logger.info/1`

- Backwards incompatible changes
    - Completely unknown devices now yield `:unknown` instead of
      a struct with all values set to `:unknown`
    - Downloads are now done using `:hackney` instead of `mix`. This may force
      you to manually reconfigure the client
    - Minimum required elixir version is now "~> 1.2"
    - Minimum required erlang version is now "~> 18.0"

## v0.11.1 (2016-04-02)

- Bug fixes
    - Properly handles short code map files after upstream changes

## v0.11.0 (2016-03-28)

- Enhancements
    - Databases are reloaded if a storage process gets restarted
    - HbbTV version can be fetched using `hbbtv?/1`
    - Path can be configured by accessing the system environment
      ([#5](https://github.com/elixytics/ua_inspector/pull/5))
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
