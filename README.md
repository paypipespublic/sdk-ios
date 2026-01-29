# PayPipes iOS SDK

[![Version](https://img.shields.io/badge/version-1.0.3-blue.svg)](https://github.com/paypipespublic/punext-pms-sdk-ios)
[![Platform](https://img.shields.io/badge/platform-iOS%2015.0%2B-lightgrey.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/swift-5.9-orange.svg)](https://swift.org)
![License](https://img.shields.io/badge/license-Proprietary-red.svg)

PayPipes SDK provides a seamless and secure payment processing solution for iOS applications. This SDK handles card payment transactions, card storage, and 3D Secure authentication flows.

## Features

- 💳 **Card Payment Processing**: Complete payment flow with card validation
- 🔒 **Security First**: SSL pinning, device integrity checks, secure data handling
- 🎨 **Customizable Theming**: Match your app's design system
- 🌍 **Localization**: Multi-language support
- ✅ **3D Secure**: Full support for 3DS authentication flows

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the PayPipes SDK to your project using Swift Package Manager:

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/paypipespublic/punext-pms-sdk-ios.git
   ```
3. Select the version you want to use (or use the latest)
4. Add the `PayPipes` package to your target

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/paypipespublic/punext-pms-sdk-ios.git", from: "1.0.3")
]
```

### Manual Integration

1. Download the `PayPipes.xcframework` from the [Releases](https://github.com/paypipespublic/punext-pms-sdk-ios/releases) page
2. Drag `PayPipes.xcframework` into your Xcode project
3. In your target's **General** settings, add `PayPipes.xcframework` to **Frameworks, Libraries, and Embedded Content**
4. Ensure **Embed & Sign** is selected

## Quick Start

### 1. Import the SDK

```swift
import PayPipes
```

### 2. Configure the SDK

```swift
let configuration = Configuration(
    clientId: "your-client-id",
    clientSecret: "your-client-secret",
    companyName: "Your Company",
    termsUrl: URL(string: "https://yourcompany.com/terms")!,
    environment: .production, // or .sandbox
    theme: .default,
    isLoggingEnabled: false,
    language: nil // Use system language, or .english, .czech
)
```

### 3. Create a Transaction

```swift
// CustomerDetails is required
let customerDetails = CustomerDetails(
    firstName: "John",
    lastName: "Smith",
    email: "john.smith@example.com",
    address: nil, // Optional
    phone: nil, // Optional
    legalEntity: .private, // or .business
    referenceId: nil // Optional: your unique customer identifier
)

let amount = Money(amount: 10.00, currency: "USD")
let transaction = CardTransaction(
    amount: amount,
    orderId: UUID().uuidString,
    customerDetails: customerDetails,
    flowType: .cardPayment,
    billingAddressRequired: false,
    callbackUrl: nil // Optional: URL for server callbacks
)
```

### 4. Present the Payment UI

#### UIKit

```swift
do {
    let transactionController = try PayPipesUI.buildCardTransactionController(
        with: configuration,
        transaction: transaction,
        completion: { result in
            switch result {
            case .success(let details):
                print("Transaction ID: \(details.transactionId)")
                print("Customer Token: \(details.customerToken)")
            case .failure(let failure):
                print("Error: \(failure.error)")
                // Partial data may be available
                if let txnId = failure.transactionId {
                    print("Transaction ID: \(txnId)")
                }
                if let token = failure.customerToken {
                    print("Customer Token: \(token)")
                }
            }
        }
    )
    transactionController.modalPresentationStyle = .fullScreen
    present(transactionController, animated: true)
} catch {
    print("Failed to initialize SDK: \(error)")
}
```

#### SwiftUI

```swift
import SwiftUI
import PayPipes

struct PaymentView: View {
    @State private var showPayment = false
    
    var body: some View {
        Button("Pay") {
            showPayment = true
        }
        .payPipesUI(
            isPresented: $showPayment,
            configuration: configuration,
            transaction: transaction
        ) { result in
            switch result {
            case .success(let details):
                print("Transaction ID: \(details.transactionId)")
                print("Customer Token: \(details.customerToken)")
            case .failure(let failure):
                print("Error: \(failure.error)")
            }
        }
    }
}
```

## Configuration

### Custom Theme

```swift
let customTheme = Theme(
    colors: Theme.Colors(
        screenBackgroundColor: UIColor.systemBackground,
        buttonBackgroundColor: UIColor.systemBlue,
        buttonTitleColor: .white
        // ... customize other colors
    ),
    fonts: Theme.Fonts(
        buttonTitleFont: .boldSystemFont(ofSize: 16)
        // ... customize other fonts
    )
)

let configuration = Configuration(
    clientId: "your-client-id",
    clientSecret: "your-client-secret",
    companyName: "Your Company",
    termsUrl: URL(string: "https://yourcompany.com/terms")!,
    environment: .production,
    theme: customTheme
)
```

### Customer Details

**CustomerDetails is mandatory** for all transactions. The following fields are required:
- `firstName: String` - Customer's first name
- `lastName: String` - Customer's last name  
- `email: String` - Customer's email address

The following fields are optional:
- `address: Address?` - Customer's billing address
- `phone: Phone?` - Customer's phone number
- `legalEntity: LegalEntity` - `.private` (default) or `.business`
- `referenceId: String?` - Your unique customer identifier (max 255 chars)

```swift
// Minimal required CustomerDetails
let minimalCustomerDetails = CustomerDetails(
    firstName: "John",
    lastName: "Smith",
    email: "john.smith@example.com"
)

// Complete CustomerDetails with all fields
let completeCustomerDetails = CustomerDetails(
    firstName: "John",
    lastName: "Smith",
    email: "john.smith@example.com",
    address: Address(
        street: "123 Main St",
        city: "New York",
        state: "NY",
        postCode: "10001",
        country: "US"
    ),
    phone: Phone(number: "1234567890", countryCode: "+1"),
    legalEntity: .private,
    referenceId: "customer-123"
)

let transaction = CardTransaction(
    amount: amount,
    orderId: UUID().uuidString,
    customerDetails: completeCustomerDetails,
    flowType: .cardPayment,
    billingAddressRequired: true,
    callbackUrl: URL(string: "https://yourserver.com/callback")
)
```

## Sample App

See the `SampleApp` directory for a complete example application demonstrating:
- UIKit integration
- SwiftUI integration
- Theme customization
- Billing address handling
- Error handling

## API Reference

### PayPipesUI

The main entry point for the SDK.

#### Methods

- `buildCardTransactionController(with:transaction:completion:)` - Creates a UIKit view controller for card transactions
- `updateTheme(_:)` - Updates the SDK theme at runtime

### CardTransaction

Represents a payment transaction.

#### Properties

- `amount: Money` - The transaction amount
- `orderId: String` - Unique order identifier
- `customerDetails: CustomerDetails` - **Required** customer information
- `flowType: FlowType` - Transaction type (`.cardPayment` or `.cardStorage`)
- `billingAddressRequired: Bool` - Whether billing address is required
- `callbackUrl: URL?` - Optional URL for server callbacks

### CustomerDetails

Represents customer information for a transaction.

#### Required Properties

- `firstName: String` - Customer's first name
- `lastName: String` - Customer's last name
- `email: String` - Customer's email address

#### Optional Properties

- `address: Address?` - Customer's billing address
- `phone: Phone?` - Customer's phone number
- `legalEntity: LegalEntity` - `.private` (default) or `.business`
- `referenceId: String?` - Your unique customer identifier (max 255 chars)

### Configuration

SDK configuration settings.

#### Properties

- `clientId: String` - Your client ID
- `clientSecret: String` - Your client secret
- `companyName: String` - Displayed in payment form
- `termsUrl: URL` - URL to your terms and conditions
- `environment: Environment` - `.production` or `.sandbox`
- `theme: Theme` - UI theme (default: `.default`)
- `isLoggingEnabled: Bool` - Enable SDK logging (default: `false`)
- `isScreenCaptureEnabled: Bool` - Allow screenshots (default: `false`)
- `language: SDKLanguage?` - Override display language (`.english`, `.czech`)

## Error Handling

The SDK provides detailed error information:

```swift
switch result {
case .success(let details):
    let transactionId = details.transactionId
    let customerToken = details.customerToken
    
case .failure(let failure):
    switch failure.error {
    case .compromisedDevice:
        // Device is jailbroken
    case .canceled:
        // User cancelled the transaction
    case .declined(let code):
        // Transaction was declined: code.rawValue
    case .noSchemeForCurrency:
        // No payment scheme available for currency
    case .unknownTransactionState:
        // Transaction state could not be determined
    case .serverError(let error):
        // Server-side error: error.message
    case .invalidInput:
        // Input validation failed
    }
    
    // Partial data may be available even on failure
    if let txnId = failure.transactionId {
        print("Transaction was created: \(txnId)")
    }
    if let token = failure.customerToken {
        print("Customer was created: \(token)")
    }
}
```

## Security

- **SSL Pinning**: All network requests use SSL pinning for enhanced security
- **Device Integrity**: The SDK checks for compromised devices (jailbreak/root)
- **Secure Storage**: Sensitive data is handled securely
- **Screen Protection**: Screenshots are prevented during payment flows

## Support

For issues, questions, or feature requests, please contact:
- Email: pnemecek@purple-technology.com

## License

Proprietary - All rights reserved.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

