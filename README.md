# PayPipes SDK for iOS

A secure, customizable payment SDK for iOS applications.

## Requirements

- **iOS**: 15.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+

## Installation

### Swift Package Manager

Add the PayPipes SDK to your project:

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL
3. Select the version and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://your-repo/PayPipes.git", from: "1.0.3")
]
```

### Manual Installation

1. Download `PayPipes.xcframework`
2. Drag it into your Xcode project
3. Ensure it's added to **Frameworks, Libraries, and Embedded Content** with "Embed & Sign"

## Quick Start

### 1. Initialize Configuration

```swift
let configuration = Configuration(
    clientId: "your-client-id",
    clientSecret: "your-client-secret",
    companyName: "Your Company",
    termsUrl: URL(string: "https://yourcompany.com/terms")!,
    environment: .sandbox,  // Use .production for live
    isLoggingEnabled: true  // Set to false in production
)
```

### 2. Create Customer Details

```swift
let customerDetails = CustomerDetails(
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
    phone: Phone(number: "5551234567", countryCode: "+1"),
    legalEntity: .private,  // or .business
    referenceId: "customer-123"  // Optional: your unique customer identifier
)
```

### 3. Create Transaction

```swift
let transaction = CardTransaction(
    amount: Money(amount: 10.00, currency: "USD"),
    orderId: UUID().uuidString,
    customerDetails: customerDetails,
    flowType: .cardPayment,  // or .cardStorage
    billingAddressRequired: false,
    callbackUrl: URL(string: "https://yourserver.com/callback")  // Optional
)
```

### 4. Present Payment UI

```swift
do {
    let controller = try PayPipesUI.buildCardTransactionController(
        with: configuration,
        transaction: transaction
    ) { result in
        self.handleResult(result)
    }
    
    controller.modalPresentationStyle = .fullScreen
    present(controller, animated: true)
} catch {
    // Handle initialization error (e.g., jailbroken device)
    print("Failed to initialize: \(error)")
}
```

### 5. Handle Results

```swift
private func handleResult(_ result: CardTransactionResult) {
    switch result {
    case .success(let details):
        let transactionId = details.transactionId
        let customerToken = details.customerToken
        // Payment successful
        
    case .failure(let failure):
        switch failure.error {
        case .declined(let code):
            // Payment declined: code.rawValue
        case .canceled:
            // User cancelled
        case .serverError(let error):
            // Server error: error.message
        // Handle other error types...
        default:
            break
        }
        
        // Partial data may be available
        if let txnId = failure.transactionId {
            // Transaction was created before failure
        }
        if let token = failure.customerToken {
            // Customer was created before failure
        }
    }
}
```

## SwiftUI Integration

```swift
import SwiftUI
import PayPipes

struct PaymentView: View {
    @State private var showPayment = false
    
    var body: some View {
        Button("Pay Now") {
            showPayment = true
        }
        .payPipesUI(
            isPresented: $showPayment,
            configuration: configuration,
            transaction: transaction
        ) { result in
            handleResult(result)
        }
    }
}
```

## Configuration Options

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `clientId` | `String?` | * | Your client ID |
| `clientSecret` | `String?` | * | Your client secret |
| `accessToken` | `String?` | * | Pre-obtained OAuth token (alternative to clientId/clientSecret) |
| `companyName` | `String` | Yes | Displayed in payment form |
| `termsUrl` | `URL` | Yes | URL to your terms and conditions |
| `environment` | `Environment` | Yes | `.sandbox` or `.production` |
| `theme` | `Theme` | No | Custom UI theme (default: `.default`) |
| `isLoggingEnabled` | `Bool` | No | Enable SDK logging (default: `false`) |
| `isScreenCaptureEnabled` | `Bool` | No | Allow screenshots (default: `false`) |
| `language` | `SDKLanguage?` | No | Override display language |

\* Either `accessToken` OR both `clientId` and `clientSecret` must be provided.

## Transaction Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `amount` | `Money` | Yes | Transaction amount and currency |
| `orderId` | `String` | Yes | Unique order identifier |
| `customerDetails` | `CustomerDetails` | Yes | Customer information |
| `flowType` | `FlowType` | No | `.cardPayment` (default) or `.cardStorage` |
| `billingAddressRequired` | `Bool` | No | Require billing address (default: `false`) |
| `callbackUrl` | `URL?` | No | Server callback URL for status updates |

## Customer Details

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `firstName` | `String` | Yes | Customer's first name |
| `lastName` | `String` | Yes | Customer's last name |
| `email` | `String` | Yes | Customer's email address |
| `address` | `Address?` | No | Billing address |
| `phone` | `Phone?` | No | Phone number |
| `legalEntity` | `LegalEntity` | No | `.private` (default) or `.business` |
| `referenceId` | `String?` | No | Your unique customer ID (max 255 chars) |

## Theming

Customize the SDK appearance:

```swift
let customTheme = Theme(
    colors: Theme.Colors(
        screenBackgroundColor: UIColor(hex: "F5F5F5"),
        buttonBackgroundColor: UIColor(hex: "3F51B5"),
        buttonTitleColor: .white
        // ... more color options
    ),
    fonts: Theme.Fonts(
        buttonTitleFont: .boldSystemFont(ofSize: 16)
        // ... more font options
    )
)

let configuration = Configuration(
    // ...
    theme: customTheme
)
```

## Localization

Supported languages: English (`.english`), Czech (`.czech`)

```swift
let configuration = Configuration(
    // ...
    language: .czech  // Override system language
)
```

## Error Types

| Error | Description |
|-------|-------------|
| `.compromisedDevice` | Device is jailbroken |
| `.canceled` | User cancelled the transaction |
| `.declined(code)` | Transaction was declined |
| `.noSchemeForCurrency` | No payment scheme for currency |
| `.unknownTransactionState` | Transaction state undetermined |
| `.serverError(error)` | Server-side error |
| `.invalidInput` | Input validation failed |

## Security

- The SDK refuses to run on jailbroken devices
- Screen capture is disabled by default
- Card data is encrypted using JWE before transmission
- SSL certificate pinning is enforced

## Sample App

See the `SampleApp/` directory for a complete integration example.

## Support

For integration support, contact: pnemecek@purple-technology.com
