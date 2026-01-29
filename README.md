# PayPipes iOS SDK

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/paypipespublic/punext-pms-sdk-ios)
[![Platform](https://img.shields.io/badge/platform-iOS%2016.6%2B-lightgrey.svg)](https://developer.apple.com/ios/)
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

- iOS 16.6+
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
    .package(url: "https://github.com/paypipespublic/punext-pms-sdk-ios.git", from: "1.0.0")
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
    environment: .production, // or .sandbox
    theme: nil // Use default theme, or provide custom theme
)
```

### 3. Create a Transaction

```swift
// BillingInfo is required - create it with mandatory fields
let billingInfo = BillingInfo(
    firstName: "John",
    lastName: "Smith",
    email: "john.smith@example.com",
    address: nil, // Optional
    phone: nil // Optional
)

let amount = Money(amount: 10.00, currency: "USD")
let transaction = CardTransaction(
    amount: amount,
    orderId: UUID().uuidString,
    billingInfo: billingInfo,
    flowType: .cardPayment,
    billingAddressRequired: false
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
                print("Payment successful: \(details.transactionId)")
            case .failure(let error):
                print("Payment failed: \(error)")
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
                print("Payment successful: \(details.transactionId)")
            case .failure(let error):
                print("Payment failed: \(error)")
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
        primary: .systemBlue,
        background: .systemBackground,
        // ... customize other colors
    ),
    fonts: Theme.Fonts(
        title: .systemFont(ofSize: 24, weight: .bold),
        // ... customize other fonts
    )
)

let configuration = Configuration(
    clientId: "your-client-id",
    clientSecret: "your-client-secret",
    environment: .production,
    theme: customTheme
)
```

### Billing Address

**BillingInfo is mandatory** for all transactions. The following fields are required:
- `firstName: String` - Customer's first name
- `lastName: String` - Customer's last name  
- `email: String` - Customer's email address

The following fields are optional:
- `address: Address?` - Optional billing address
- `phone: Phone?` - Optional phone number

```swift
// Minimal required BillingInfo
let minimalBillingInfo = BillingInfo(
    firstName: "John",
    lastName: "Smith",
    email: "john.smith@example.com",
    address: nil,
    phone: nil
)

// Complete BillingInfo with address and phone
let completeBillingInfo = BillingInfo(
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
    phone: Phone(number: "1234567890", countryCode: "+1")
)

let transaction = CardTransaction(
    amount: amount,
    orderId: UUID().uuidString,
    billingInfo: completeBillingInfo, // Required - cannot be nil
    flowType: .cardPayment,
    billingAddressRequired: true
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
- `billingInfo: BillingInfo` - **Required** billing information (cannot be nil)
- `flowType: FlowType` - Transaction type (`.cardPayment` or `.cardStorage`)
- `billingAddressRequired: Bool` - Whether billing address is required

### BillingInfo

Represents billing information for a customer.

#### Required Properties

- `firstName: String` - Customer's first name (required)
- `lastName: String` - Customer's last name (required)
- `email: String` - Customer's email address (required)

#### Optional Properties

- `address: Address?` - Customer's billing address (optional)
- `phone: Phone?` - Customer's phone number (optional)

### Configuration

SDK configuration settings.

#### Properties

- `clientId: String` - Your client ID
- `clientSecret: String` - Your client secret
- `environment: Environment` - `.production` or `.sandbox`
- `theme: Theme?` - Optional custom theme

## Error Handling

The SDK provides detailed error information:

```swift
switch result {
case .success(let details):
    // Transaction successful
    let transactionId = details.transactionId
case .failure(let error):
    switch error {
    case .cancelled:
        // User cancelled the transaction
    case .networkError(let message):
        // Network error occurred
    case .validationError(let message):
        // Validation failed
    case .securityError(let message):
        // Security check failed (e.g., jailbroken device)
    default:
        // Other errors
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

