# Change log

## [0.1.1] - 2024-05-04

  * Added utility class Garnet::Utils::Cipher for cryto encryption
  * Added support in Garnet::ProviderSources::Persistence for database password encryption/decryption via environment variable DB_PASSWORD_ENCRYPTED.
  * Added cipher utility Rake tasks
  * Fixed rubocop issues

## [0.1.0] - 2024-02-06

- Initial release
  - container
    - application
    - service
  - actor
    - base
    - pool
  - action
  - operation
  - message
  - contract
  - provider sources
    - logger
    - persistence (rom-rb)
      - ORM (rom-rb)
      - Migration & Rake tasks
      - Support multiple databases
  - Garnet app/services
