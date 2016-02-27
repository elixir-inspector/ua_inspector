# Changelog

## v0.11.0-dev

- Enhancements
    - HbbTV version can be fetched using `hbbtv?/1`
    - Path can be configured by accessing the system environment ([#5](https://github.com/elixytics/ua_inspector/pull/5))

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
