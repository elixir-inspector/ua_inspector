# Changelog

## v0.8.0-dev

- Enhancements
  - Bots are included in the detection

- Backwards incompatible changes
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
