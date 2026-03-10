# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.7] - 2026-03-10

### Improved
- Focus automatically advances from card number → expiry → CVC as each field is completed, creating a smoother card entry flow

### Fixed
- Cardholder name is no longer sanitized before submission (removed whitespace normalization, apostrophe conversion, and forced title case)
- Country and state picker search is now diacritics-insensitive (e.g. "cesko" matches "Česko")
- Country names in billing address picker now respect the SDK language override instead of always using the device locale

## [1.0.6] - 2026-02-09

### Added
- `customerToken` parameter in `CardTransaction` as alternative to `customerDetails` for pre-tokenized customers

### Changed
- **BREAKING:** `customerDetails` in `CardTransaction` is now optional (provide either `customerDetails` or `customerToken`)

### Fixed
- Card number validation now shows "unsupported scheme" only after all other validations pass

### Changed
- `referenceId` max length reduced from 255 to 64 characters
- Cardholder name validation now uses Latin-script-only regex (`\p{Script=Latin}`, `\p{M}`, `\p{Zs}`, digits, apostrophes, hyphens)

### Fixed (Sample App)
- Added CZK currency option

## [1.0.5] - 2026-02-01

### Fixed
- Logging configuration

## [1.0.4] - 2026-01-30

### Added
- `accessToken` parameter in `Configuration` for using pre-obtained OAuth tokens
- `Configuration.ConfigurationError` enum for configuration validation errors
- SDK now supports two authentication modes:
  - Client credentials: Provide `clientId` and `clientSecret` (existing behavior)
  - Access token: Provide `accessToken` directly to skip OAuth authentication
- Verve card scheme support

### Changed
- **BREAKING:** `Configuration` initializer now throws (`init(...) throws`)
- **BREAKING:** `clientId` and `clientSecret` are now optional in `Configuration`
- Configuration validation requires either `accessToken` OR both `clientId` and `clientSecret`

## [1.0.3] - 2025-01-14

### Changed
- **BREAKING:** `CardTransactionResult` failure type changed from `CardTransactionError` to `CardTransactionFailure`
- **BREAKING:** Failure results now accessed via `failure.error` instead of directly
- **BREAKING:** `BillingInfo` renamed to `CustomerDetails`
- **BREAKING:** `CardTransaction.billingInfo` renamed to `CardTransaction.customerDetails`

### Added
- `CardTransactionFailure` struct wrapping error with optional `transactionId` and `customerToken`
- `customerToken` included in success results via `CardTransactionDetails`
- Partial transaction data (`transactionId`, `customerToken`) available in failure results
- `callbackUrl` parameter in `CardTransaction` for receiving transaction status callbacks
- `referenceId` parameter in `CustomerDetails` for customer unique identification (max 64 chars)
- `SDKLanguage` enum for explicit language selection (`.english`, `.czech`)
- `language` parameter in `Configuration` to override SDK display language
- `LanguageManager` for centralized language configuration
- Language code sent to backend in purchase requests (ISO 639-1)

## [1.0.2] - 2025-01-09

### Changed
- Expiry date validation no longer enforces maximum year limit
- Card holder validation now respects legal entity (PRIVATE requires 2 names, BUSINESS allows 1 name)

### Added
- Customer legal entity

## [1.0.1] - 2025-12-10

### Changed
- Decline transaction note updated

## [1.0.0] - 2025-12-04

### Added
- Initial SDK release
