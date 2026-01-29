# iOS SDK - Internal Developer Guide

This document provides an internal overview of the iOS SDK, covering its architecture, key components, development practices, and project structure. It is intended for developers working on the SDK itself.

## Core Objectives & Design Philosophy

*   **Provide a seamless and secure payment experience:** The primary goal is to offer a robust, easy-to-integrate, and secure solution for card payment processing within iOS applications.
*   **Modularity and Reusability:** Components are designed to be as self-contained as possible (e.g., Form System, Card Scanner) to promote reusability and maintainability.
*   **Native Look and Feel with Theming:** While offering a default UI, the SDK is themable to allow integrators to match their app's branding.
*   **Clear Error Handling:** Provide distinct and actionable error information.
*   **Security First:** Implement security best practices, including SSL pinning and careful data handling.

## Architecture Overview

The iOS SDK primarily follows an MVC (Model-View-Controller) pattern for its UI components, with distinct services for API communication and other functionalities.

*   **Models (`Source/Model/`)**:
    *   **Core (`Source/Model/Core/`)**: Core domain models and configuration (`CardTransaction`, `Configuration`, `Money`, `BillingInfo`, `CardScheme`, `Country`).
    *   **Entities (`Source/Model/Entities/`)**: Network DTOs (`CreateCustomerRequest`, `PurchaseResponse`, etc.).
    *   **Managers (`Source/Model/Manager/`)**: High-level business logic managers, specifically `ApiManager`.
    *   **Network (`Source/Model/Network/`)**: Low-level networking layer (`Service`, `Request`, `ServiceError`).
    *   **Errors**: `SDKError.swift` (high-level SDK errors) and `ServiceError` (network/API specific errors).

*   **Views (`Source/UI/`)**:
    *   **Form System (`Source/UI/Form/Views/`)**: `FormStackView` (main container), various field views (`InputFieldView`, `CardNumberFieldView`, `CheckboxFieldView`, `SubmitButtonView`, `CardSchemesHeaderView`), `InputContainerView` (handles field borders/styles).
    *   **Theming (`Source/Theme/`)**: `Theme` struct and its default implementation, `Theme.Colors`, `Theme.Fonts`, `Theme.Sizes`. `ThemeManager` provides thread-safe access to the active theme.

*   **Controllers (`Source/UI/`)**:
    *   `CardTransactionFormController`: The primary controller orchestrating the card payment flow. It manages the `FormStackView`, handles user input, performs validation, interacts with `ApiManager` for backend operations, and manages the card scanning process.
    *   `CardScannerViewController`: Manages the camera input and card scanning UI, delegating the actual scanning to the `CardScanner` utility.
    *   `ThreeDSWebViewController`: Manages the 3D Secure WebView interactions.

*   **Services & Managers**:
    *   `ApiManager`: High-level abstraction for interacting with the backend API. It uses the `Service` for actual HTTP requests and handles authentication and business logic.
    *   `Service`: Low-level networking client responsible for:
        *   Constructing and sending `URLRequest`s.
        *   SSL Pinning (using SPKI hashes from `Configuration` or defaults).
        *   Parsing responses and decoding JSON.

*   **Utilities & Helpers (`Source/Extensions/`, `Source/UI/Form/Validation/`)**:
    *   **Validation (`Source/UI/Form/Validation/`)**: `Validator` protocol and concrete implementations (`CardNumberValidator`, `CardExpiryValidator`, `CVVValidator`, `InputSanitizer`, etc.).
    *   **Extensions**: Useful extensions on `String` (Luhn check, card brand detection), `UIColor`, `Bundle`, etc.
    *   **Logging (`Source/Logging/`)**: `Logger` class for conditional logging.
    *   **Card Scanner (`Source/UI/CardScanner/`)**: Uses `AVFoundation` and `Vision` for detecting card rectangles and recognizing text.

## Key Systems Deep Dive

### Form System

*   **Data Flow**: `CardTransactionFormController` defines `FormSection`s containing `FormItem`s. These are passed to `FormStackView`.
*   **View Rendering**: `FormStackView` renders these items into a vertical stack.
*   **User Input & State**: Views directly update the `value` property of their bound `FormField` instance. `onChange` callbacks on `FormField` trigger actions in the controller.
*   **Validation**: `FormField` has a `validators: [Validator]` array and a `validate()` method. `CardTransactionFormController` orchestrates overall form validation before submission.

### Card Scanning

*   `UIImagePickerController.isScanningAvailable` checks for camera permission.
*   `CardScannerViewController` presents the camera feed.
*   `CardScanner` uses `AVCaptureSession` for input and `VNRecognizeTextRequest` for text recognition.
*   Results are passed back via closure to `CardTransactionFormController`.

### Theming

*   `Theme` struct defines customizable properties (colors, fonts, sizes).
*   `ThemeManager.shared.currentTheme` provides access to the active theme.
*   `Configuration` carries a theme which is applied via `ThemeManager` upon SDK initialization.

### Localization

The SDK supports multiple languages with an optional explicit language override:

```swift
let configuration = Configuration(
    // ... other params ...
    language: .czech  // Force Czech language
)
```

#### Supported Languages

| Language | Enum Value | ISO 639-1 |
|----------|------------|-----------|
| English | `.english` | `en` |
| Czech | `.czech` | `cs` |

#### Language Resolution

1. If `language` is explicitly set in `Configuration`, use that language
2. Otherwise, check if the system language is supported
3. Fall back to English if system language is not supported

The resolved language is:
*   Used for all SDK UI strings via `LanguageManager`
*   Sent to the backend via the `language` parameter in API requests

### Transaction Configuration

The `CardTransaction` struct defines the transaction details:

```swift
let transaction = CardTransaction(
    amount: Money(amount: 10, currency: "USD"),
    orderId: UUID().uuidString,
    customerDetails: customerDetails,
    flowType: .cardPayment,
    billingAddressRequired: false,
    callbackUrl: URL(string: "https://example.com/callback")  // Optional
)
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `amount` | `Money` | Yes | Transaction amount and currency |
| `orderId` | `String` | Yes | Unique identifier for the order |
| `customerDetails` | `CustomerDetails` | Yes | Customer details including billing information |
| `flowType` | `FlowType` | No | `.cardPayment` (default) or `.cardStorage` |
| `billingAddressRequired` | `Bool` | No | Whether to collect billing address (default: `false`) |
| `callbackUrl` | `URL?` | No | URL for receiving transaction status callbacks |

#### Customer Details

`CustomerDetails` contains the customer information for the transaction:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `firstName` | `String` | Yes | Customer's first name |
| `lastName` | `String` | Yes | Customer's last name |
| `email` | `String` | Yes | Customer's email address |
| `address` | `Address?` | No | Customer's billing address |
| `phone` | `Phone?` | No | Customer's phone number |
| `legalEntity` | `LegalEntity` | No | `.private` (default) or `.business` |
| `referenceId` | `String?` | No | Unique customer identifier (max 255 chars) |

#### Callback URL

The optional `callbackUrl` parameter allows you to receive transaction status updates from the server:

*   Must use HTTP or HTTPS scheme
*   Maximum length: 2048 characters
*   Invalid URLs are silently ignored (treated as `nil`)

### Result Handling

The SDK uses Swift's `Result` type for transaction outcomes:

```swift
public typealias CardTransactionResult = Result<CardTransactionDetails, CardTransactionFailure>
```

#### Success Result

`CardTransactionDetails` contains:
*   `transactionId: String` - The unique transaction identifier
*   `customerToken: String` - The customer token for future transactions

#### Failure Result

`CardTransactionFailure` wraps the error with optional partial data:
*   `error: CardTransactionError` - The specific error that occurred
*   `transactionId: String?` - Transaction ID if one was created before failure
*   `customerToken: String?` - Customer token if one was created before failure

This design allows integrators to access partial transaction data even when an error occurs (e.g., when a transaction was created but later declined).

#### Usage Example

```swift
PayPipesUI.buildCardTransactionController(
    with: configuration,
    transaction: transaction
) { result in
    switch result {
    case .success(let details):
        print("Transaction ID: \(details.transactionId)")
        print("Customer Token: \(details.customerToken)")
        
    case .failure(let failure):
        print("Error: \(failure.error)")
        // Access partial data if available
        if let txnId = failure.transactionId {
            print("Partial Transaction ID: \(txnId)")
        }
        if let token = failure.customerToken {
            print("Partial Customer Token: \(token)")
        }
    }
}
```

#### Error Types (`CardTransactionError`)

| Error | Description |
|-------|-------------|
| `.compromisedDevice` | Device is jailbroken/rooted |
| `.canceled` | User cancelled the transaction |
| `.declined(CardTransactionDeclineCode)` | Transaction was declined |
| `.noSchemeForCurrency` | No payment scheme available for currency |
| `.unknownTransactionState` | Transaction state could not be determined |
| `.serverError(ServerError)` | Server-side error occurred |
| `.invalidInput` | Input validation failed |

## Project Structure

*   **/PayPipes**: The main SDK source code.
    *   **/Source**: All Swift source files.
        *   **/UI**: UI components, ViewControllers, and Form system.
        *   **/Model**: Data models, Networking, and Managers.
        *   **/Theme**: Theming system.
        *   **/Security**: Secure data handling (`SecureString`, `JWEEncryption`).
        *   **/Extensions**: Helper extensions.
        *   **/Logging**: Logger implementation.
*   **/ExampleApp**: A simple application demonstrating how to integrate and use the SDK.
*   **/PayPipesTests**: Unit and integration tests.

### ⚠️ Security Warning: Handling Credentials

**Do not hardcode your `clientId` and `clientSecret` in your production code.**

The provided `ExampleApp` hardcodes credentials for demonstration purposes only. For a production application, you should store and load these secrets securely.

## Development Guidelines

*   **Code Style**: Adhere to Swift API Design Guidelines.
*   **Dependency Management**: The SDK avoids external dependencies to minimize conflict for integrators.
*   **API Design**: Public APIs are carefully considered and documented. `PayPipesUI` is the main entry point.
*   **Error Handling**: Utilize `CardTransactionFailure` (wraps `CardTransactionError` with partial data) and `SDKError`.
*   **Localization**: Localization is handled via `String(localized:bundle:)` using keys in `Localizable.xcstrings`.

## Key Contacts & Maintainers

*   Pavel Nemecek, pnemecek@purple-technology.com

---
*This document is for internal use. Information may change as the SDK evolves.*
