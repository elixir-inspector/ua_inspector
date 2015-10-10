# Changelog

## v0.9.0-dev

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
