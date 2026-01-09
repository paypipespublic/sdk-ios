//
//  SwiftUISampleView.swift
//  ExampleApp
//
//  Copyright © 2025 Purple Next s.r.o. All rights reserved.
//

import PayPipes
import SwiftUI

// MARK: - SwiftUISampleView

/**
 * Example SwiftUI View demonstrating PayPipes SDK integration.
 *
 * This example demonstrates:
 * - Integrating the SDK using the `.payPipesUI` modifier
 * - Handling transaction state and results
 * - Configuring transaction details (amount, currency)
 * - Configuring billing address requirements and pre-filling
 * - Customizing the SDK theme
 */
struct SwiftUISampleView: View {
    // MARK: - Internal

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("PayPipes SDK Example (SwiftUI)")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("This example demonstrates how to integrate the PayPipes SDK for iOS with theming.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Text("Amount").font(.system(size: 18, weight: .bold)).foregroundColor(Color(UIColor(hex: "1976D2")))

                TextField("Amount", text: $amount)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)

                Picker("Currency", selection: $selectedCurrency) {
                    Text("USD").tag("USD")
                    Text("EUR").tag("EUR")
                    Text("JPY").tag("JPY")
                }.pickerStyle(.segmented)

                Text("Customer").font(.system(size: 18, weight: .bold)).foregroundColor(Color(UIColor(hex: "1976D2")))

                VStack(spacing: 12) {
                    TextField("First Name", text: $firstName).textFieldStyle(.roundedBorder)
                    TextField("Last Name", text: $lastName).textFieldStyle(.roundedBorder)
                    TextField("Email", text: $email).textFieldStyle(.roundedBorder)

                    Divider()

                    Toggle(isOn: $billingAddressRequired) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Billing address required")
                                .font(.system(size: 16, weight: .medium))
                            Text("Billing address required during purchase")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    Toggle(isOn: $billingAddressProvided) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Billing address provided")
                                .font(.system(size: 16, weight: .medium))
                            Text("Billing address provided by the merchant")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    Toggle(isOn: $isBusinessCustomer) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Business customer")
                                .font(.system(size: 16, weight: .medium))
                            Text("Set legal entity to business")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                Text("Custom Theme").font(.system(size: 18, weight: .bold)).foregroundColor(Color(UIColor(hex: "1976D2")))

                VStack(spacing: 12) {
                    Toggle(isOn: $isCustomThemeEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apply Custom Theme")
                                .font(.system(size: 16, weight: .medium))
                            Text("Apply a blue custom theme to the SDK UI")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                Button(action: {
                    isPresentingPayPipes = true
                }) {
                    Text(paymentButtonTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button(action: {
                    isPresentingPayPipes = true
                }) {
                    Text("Test Card Storage")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(12)
                }

                Text("Features demonstrated:")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(UIColor(hex: "1976D2")))
                Text([
                    "• Card payment processing",
                    "• Card storage for future payments",
                    "• Multi-currency support (USD, EUR, JPY)",
                    "• Optional billing address collection",
                    "• Result callbacks",
                    "• Custom theming system"
                ].joined(separator: "\n"))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemBackground))
        .navigationTitle("SwiftUI Example")
        .modifier(PayPipesEntryModifier(
            isPresented: $isPresentingPayPipes,
            configuration: configuration,
            currency: selectedCurrency,
            amount: amount,
            billingAddressRequired: billingAddressRequired,
            buildBillingInfo: buildBillingInfo,
            showAlert: $showAlert,
            alertTitle: $alertTitle,
            alertMessage: $alertMessage
        ))
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Private

    @State private var isPresentingPayPipes = false
    @State private var selectedCurrency: String = Constants.defaultCurrency
    @State private var amount: String = Constants.defaultAmount
    @State private var billingAddressRequired: Bool = false
    @State private var billingAddressProvided: Bool = false
    @State private var isBusinessCustomer: Bool = false
    @State private var firstName: String = Constants.defaultFirstName
    @State private var lastName: String = Constants.defaultLastName
    @State private var email: String = Constants.defaultEmail
    @State private var isCustomThemeEnabled: Bool = false
    
    // Alert state
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    private var configuration: Configuration {
        guard let termsUrl = URL(string: Constants.termsUrlString) else {
            fatalError("Invalid terms URL. Please check Constants.termsUrlString")
        }

        return Configuration(
            clientId: Constants.clientId,
            clientSecret: Constants.clientSecret,
            companyName: Constants.companyName,
            termsUrl: termsUrl,
            environment: .sandbox,
            theme: isCustomThemeEnabled ? customTheme : .default,
            isLoggingEnabled: true
        )
    }

    private var paymentButtonTitle: String {
        return "Test Card Payment"
    }

    private var customTheme: Theme {
        // Comprehensive custom theme demonstrating ALL available theme properties
        let colors = Theme.Colors(
            // Screen colors
            screenBackgroundColor: UIColor(hex: "F5F5F5"), // Light gray background
            primaryTextColor: UIColor(hex: "212121"), // Almost black for primary text
            secondaryTextColor: UIColor(hex: "757575"), // Medium gray for secondary text
            linkColor: UIColor(hex: "3F51B5"), // Indigo for links and interactive elements
            
            // Section and input colors
            sectionTitleColor: UIColor(hex: "1A237E"), // Deep indigo for section titles
            inputTitleColor: UIColor(hex: "424242"), // Dark gray for input labels
            inputTextColor: UIColor(hex: "000000"), // Black for input text
            inputErrorColor: UIColor(hex: "D32F2F"), // Red for error messages
            
            // Input border colors
            inputFocusedBorderColor: UIColor(hex: "3F51B5"), // Indigo for focused borders
            inputNormalBorderColor: UIColor(hex: "BDBDBD"), // Light gray for normal borders
            inputErrorBorderColor: UIColor(hex: "D32F2F"), // Red for error borders
            
            // Button colors
            buttonBackgroundColor: UIColor(hex: "3F51B5"), // Indigo button background
            buttonTitleColor: .white, // White button text
            
            // Checkbox colors
            checkboxCheckedColor: UIColor(hex: "3F51B5"), // Indigo for checked state
            checkboxUnCheckedColor: UIColor(hex: "757575"), // Medium gray for unchecked state
            
            // Picker colors
            pickerTitleColor: UIColor(hex: "212121") // Almost black for picker text
        )

        let fonts = Theme.Fonts(
            // Section and text fonts
            sectionTitleFont: .boldSystemFont(ofSize: 18), // Bold 18pt for section titles
            primaryTextFont: .systemFont(ofSize: 17, weight: .regular), // Regular 17pt for primary text
            secondaryTextFont: .systemFont(ofSize: 13, weight: .regular), // Regular 13pt for secondary text
            
            // Input fonts
            inputTitleFont: .systemFont(ofSize: 15, weight: .medium), // Medium 15pt for input labels
            inputTextFont: .systemFont(ofSize: 17, weight: .regular), // Regular 17pt for input text
            inputErrorFont: .systemFont(ofSize: 13, weight: .regular), // Regular 13pt for error messages
            
            // Button and interactive fonts
            buttonTitleFont: .boldSystemFont(ofSize: 16), // Bold 16pt for button text
            checkboxTitleFont: .systemFont(ofSize: 15, weight: .regular), // Regular 15pt for checkbox labels
            pickerTitleFont: .systemFont(ofSize: 17, weight: .semibold) // Semibold 17pt for picker text
        )
        return Theme(colors: colors, fonts: fonts)
    }

    private func buildBillingInfo() -> BillingInfo {
        BillingInfo(
            firstName: firstName,
            lastName: lastName,
            email: email,
            address: billingAddressProvided ? Constants.sampleAddress : nil,
            phone: Constants.samplePhone,
            legalEntity: isBusinessCustomer ? .business : .private
        )
    }

    private func makeTransaction(flowType: FlowType, amount: Money) -> CardTransaction {
        CardTransaction(
            amount: amount,
            orderId: UUID().uuidString,
            billingInfo: buildBillingInfo(),
            flowType: flowType,
            billingAddressRequired: billingAddressRequired
        )
    }
}

// MARK: - PayPipesEntryModifier

private struct PayPipesEntryModifier: ViewModifier {
    // MARK: - Internal

    @Binding var isPresented: Bool

    let configuration: Configuration
    let currency: String
    let amount: String
    let billingAddressRequired: Bool
    let buildBillingInfo: () -> BillingInfo
    @Binding var showAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String

    func body(content: Content) -> some View {
        let defaultAmountValue = Double(Constants.defaultAmount) ?? 10.0
        let amountValue = Decimal(Double(amount) ?? defaultAmountValue)
        let transaction = CardTransaction(
            amount: Money(amount: amountValue, currency: currency),
            orderId: orderSeed.uuidString,
            billingInfo: buildBillingInfo(),
            flowType: .cardPayment,
            billingAddressRequired: billingAddressRequired
        )

        return content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // Generate a fresh orderId for each presentation
                    orderSeed = UUID()
                }
            }
            .payPipesUI(
                isPresented: $isPresented,
                configuration: configuration,
                transaction: transaction
            ) { result in
                handleTransactionResult(result)
            }
    }

    // MARK: - Private

    @State private var orderSeed = UUID()

    private func handleTransactionResult(_ result: CardTransactionResult) {
        switch result {
        case let .success(details):
            let successMessage = "Payment successful! Transaction ID: \(details.transactionId)"
            print("✅ \(successMessage)")
            alertTitle = "Success"
            alertMessage = successMessage
            showAlert = true
            
        case let .failure(error):
            let errorMessage: String
            switch error {
            case let .declined(code):
                errorMessage = "Payment was declined \(code.rawValue)"
            case .canceled:
                errorMessage = "Payment was cancelled"
            case .noSchemeForCurrency:
                errorMessage = "No payment scheme available for currency"
            case .uknownTransactionState:
                errorMessage = "Unknown transaction state - waiting"
            case .invalidInput:
                errorMessage = "Invalid input"
            case .compromisedDevice:
                errorMessage = "Device is compromised"
            case let .serverError(srvError):
                errorMessage = "Server error \(srvError.code)"
            @unknown default:
                errorMessage = "Unknown error"
            }
            print("❌ Transaction failed: \(errorMessage) [code=\(error.code)]")
            alertTitle = "Payment Failed"
            alertMessage = errorMessage
            showAlert = true
        }
    }
}

// MARK: - Constants

private enum Constants {
    static let clientId = "[YOUR CLIENT ID]"
    static let clientSecret = "[YOUR CLIENT SECRET]"
    static let companyName = "[YOUR COMPANY NAME]"
    static let termsUrlString = "https://www.paypipes.com"

    static let defaultAmount = "10"
    static let defaultCurrency = "USD"
    static let defaultFirstName = "John"
    static let defaultLastName = "Smith"
    static let defaultEmail = "john.smith@example.com"

    static let sampleAddress = Address(
        street: "123 Fake Street",
        city: "Test City",
        state: "TS",
        postCode: "00000",
        country: "US"
    )
    static let samplePhone = Phone(number: "5550100", countryCode: "+1")
}
