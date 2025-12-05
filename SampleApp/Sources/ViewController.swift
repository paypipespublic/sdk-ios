//
//  ViewController.swift
//  ExampleApp
//
//  Copyright © 2025 Purple Next s.r.o. All rights reserved.
//

import PayPipes
import UIKit

// MARK: - ViewController

/**
 * Example ViewController demonstrating PayPipes SDK integration
 *
 * This example shows how to:
 * 1. Initialize PayPipes SDK with configuration
 * 2. Create card payment transactions
 * 3. Create card storage transactions
 * 4. Handle transaction results and errors
 * 5. Present the payment UI modally
 * 6. Configure billing address collection and pre-filling
 *
 * For production use, replace the test credentials with your actual credentials
 * and implement proper error handling and logging.
 */
class ViewController: UIViewController {
    // MARK: - Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updatePaymentButtonText()
    }

    // MARK: - Private

    // MARK: - State

    private var appliedTheme: Theme?
    private var selectedCurrency = Constants.defaultCurrency
    private var amount = Constants.defaultAmount
    private var billingAddressRequired = false
    private var billingAddressProvided = false
    private var isCustomThemeEnabled = false

    // Billing info state
    private var firstName = Constants.defaultFirstName
    private var lastName = Constants.defaultLastName
    private var email = Constants.defaultEmail

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PayPipes SDK Example"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "This example demonstrates how to integrate the PayPipes SDK for iOS with theming."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var paymentButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Test Card Payment"
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 12

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(presentPaymentController), for: .touchUpInside)
        button.accessibilityLabel = "Test Card Payment"
        button.accessibilityHint = "Opens the PayPipes payment flow"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var cardStorageButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Test Card Storage"
        configuration.baseBackgroundColor = .systemGreen
        configuration.baseForegroundColor = .white
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 12

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(presentCardStorageController), for: .touchUpInside)
        button.accessibilityLabel = "Test Card Storage"
        button.accessibilityHint = "Opens the PayPipes card storage flow"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var currencyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(hex: "1976D2")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var currencySegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["USD", "EUR", "JPY"])
        segmentedControl.selectedSegmentIndex = 0 // Default to USD
        segmentedControl.backgroundColor = .systemBackground
        segmentedControl.selectedSegmentTintColor = UIColor(hex: "2196F3")
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(hex: "1976D2")], for: .normal)
        segmentedControl.addTarget(self, action: #selector(currencyChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Amount"
        textField.text = amount
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.accessibilityLabel = "Payment amount"
        textField.accessibilityHint = "Enter the payment amount"
        textField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var billingAddressRequiredSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = billingAddressRequired
        switchControl.onTintColor = UIColor(hex: "4CAF50")
        switchControl.addTarget(self, action: #selector(billingAddressChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()

    private lazy var billingAddressProvidedSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = billingAddressProvided
        switchControl.onTintColor = UIColor(hex: "4CAF50")
        switchControl.addTarget(self, action: #selector(billingAddressProvidedChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()

    private lazy var billingAddressRequiredRow: UIView = createSwitchRow(
        title: "Billing address required",
        subtitle: "Billing address required during purchase",
        switchControl: billingAddressRequiredSwitch
    )

    private lazy var billingAddressProvidedRow: UIView = createSwitchRow(
        title: "Billing address provided",
        subtitle: "Billing address provided by the merchant",
        switchControl: billingAddressProvidedSwitch
    )

    private lazy var billingInfoContainer: UIView = {
        let divider1 = createDivider()
        let divider2 = createDivider()

        let stack = UIStackView(arrangedSubviews: [
            firstNameTextField,
            lastNameTextField,
            emailTextField,
            divider1,
            billingAddressRequiredRow,
            divider2,
            billingAddressProvidedRow
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        return container
    }()

    private lazy var billingInfoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Customer"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(hex: "1976D2")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "First Name"
        textField.text = firstName
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.addTarget(self, action: #selector(firstNameChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last Name"
        textField.text = lastName
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.addTarget(self, action: #selector(lastNameChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.text = email
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var themingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Theming"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(hex: "1976D2")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var customThemeSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = isCustomThemeEnabled
        switchControl.onTintColor = UIColor(hex: "2196F3") // Blue for theme
        switchControl.addTarget(self, action: #selector(customThemeChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()

    private lazy var customThemeContainer: UIView = {
        let row = createSwitchRow(
            title: "Apply Custom Theme",
            subtitle: "Apply a blue custom theme to the SDK UI",
            switchControl: customThemeSwitch
        )

        let stack = UIStackView(arrangedSubviews: [row])
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        return container
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
            currencyTitleLabel,
            amountTextField,
            currencySegmentedControl,
            billingInfoTitleLabel,
            billingInfoContainer,
            themingTitleLabel,
            customThemeContainer,
            paymentButton,
            cardStorageButton,
            featuresTitleLabel,
            featuresListLabel
            // Footer label is pinned to bottom, not inside stack
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var sdkVersionLabel: UILabel = {
        let label = UILabel()
        label.text = "SDK Version: \(Version.marketingVersion)"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var featuresTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Features demonstrated:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(hex: "1976D2")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var featuresListLabel: UILabel = {
        let label = UILabel()
        let features = [
            "• Card payment processing",
            "• Card storage for future payments",
            "• Multi-currency support (USD, EUR, JPY)",
            "• Optional billing address collection",
            "• Result callbacks",
            "• Custom theming system"
        ].joined(separator: "\n")
        label.text = features
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(sdkVersionLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sdkVersionLabel.topAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -32),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -64)
        ])

        NSLayoutConstraint.activate([
            sdkVersionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sdkVersionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sdkVersionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - PayPipes Configuration

    /**
     * Creates a PayPipes configuration for testing
     *
     * In production, you should:
     * - Use your actual client credentials
     * - Set environment to .production for live transactions
     * - Implement proper credential management
     * - Store credentials securely (e.g., Keychain)
     */
    private func createConfiguration() -> Configuration {
        guard let termsUrl = URL(string: Constants.termsUrlString) else {
            fatalError("Invalid terms URL. Please check Constants.termsUrlString")
        }

        return Configuration(
            clientId: Constants.clientId,
            clientSecret: Constants.clientSecret,
            companyName: Constants.companyName,
            termsUrl: termsUrl,
            environment: .sandbox,
            theme: appliedTheme ?? .default,
            isLoggingEnabled: true,
            isScreenCaptureEnabled: true
        )
    }

    /**
     * Creates sample billing information for testing
     *
     * In production, collect this information from your users
     */
    private func createSampleBillingInfo() -> BillingInfo {
        return BillingInfo(
            firstName: firstName,
            lastName: lastName,
            email: email,
            address: billingAddressProvided ? Constants.sampleAddress : nil,
            phone: Constants.samplePhone
        )
    }

    /**
     * Creates a completion handler for transaction results
     */
    private func createCompletionHandler() -> (CardTransactionResult) -> Void {
        return { [weak self] result in
            DispatchQueue.main.async {
                self?.handleTransactionResult(result)
            }
        }
    }

    /**
     * Handles the transaction result and shows appropriate UI feedback
     */
    private func handleTransactionResult(_ result: CardTransactionResult) {
        switch result {
        case let .failure(error):
            let message: String
            switch error {
            case let .declined(code): message = "Payment was declined \(code.rawValue)"
            case .canceled: message = "Payment was cancelled"
            case .noSchemeForCurrency: message = "No payment scheme available for currency"
            case .uknownTransactionState: message = "Unknown transaction state - waiting"
            case .invalidInput: message = "Invalid input"
            case .compromisedDevice: message = "Device is compromised"
            case let .serverError(srvError): message = "Server error \(srvError.code)"
            @unknown default:
                message = "Unknown error"
            }
            print("❌ Transaction failed: \(message) [code=\(error.code)]")
            presentAlert(
                title: "Payment Failed",
                message: message
            )

        case let .success(cardTransactionDetails):
            let successMessage = "Payment successful! Transaction ID: \(cardTransactionDetails.transactionId)"
            print("✅ \(successMessage)")
            presentAlert(
                title: "Success",
                message: successMessage
            )
        }
    }

    // MARK: - Action Methods

    @objc private func presentPaymentController() {
        let defaultAmountValue = Double(Constants.defaultAmount) ?? 10.0
        let amountValue = Decimal(Double(amount) ?? defaultAmountValue)
        presentTransactionController(flowType: .cardPayment, amount: Money(amount: amountValue, currency: selectedCurrency))
    }

    @objc private func presentCardStorageController() {
        presentTransactionController(flowType: .cardStorage, amount: .zero)
    }

    @objc private func currencyChanged() {
        let currencies = ["USD", "EUR", "JPY"]
        selectedCurrency = currencies[currencySegmentedControl.selectedSegmentIndex]
        updatePaymentButtonText()
    }

    @objc private func amountChanged() {
        amount = amountTextField.text ?? Constants.defaultAmount
        updatePaymentButtonText()
    }

    @objc private func billingAddressChanged() {
        billingAddressRequired = billingAddressRequiredSwitch.isOn
    }

    @objc private func billingAddressProvidedChanged() {
        billingAddressProvided = billingAddressProvidedSwitch.isOn
    }

    @objc private func firstNameChanged() {
        firstName = firstNameTextField.text ?? Constants.defaultFirstName
    }

    @objc private func lastNameChanged() {
        lastName = lastNameTextField.text ?? Constants.defaultLastName
    }

    @objc private func emailChanged() {
        email = emailTextField.text ?? Constants.defaultEmail
    }

    /**
     * Presents the PayPipes transaction controller
     *
     * - Parameter flowType: The type of transaction flow (.cardPayment or .cardStorage)
     * - Parameter amount: The transaction amount (use .zero for card storage)
     */
    private func presentTransactionController(flowType: FlowType, amount: Money) {
        let configuration = createConfiguration()
        let billingInfo = createSampleBillingInfo()
        let completion = createCompletionHandler()

        // Create transaction with provided parameters
        let transaction = CardTransaction(
            amount: amount,
            orderId: UUID().uuidString,
            billingInfo: billingInfo,
            flowType: flowType,
            billingAddressRequired: billingAddressRequired
        )

        do {
            // Build the transaction controller
            let transactionController = try PayPipesUI.buildCardTransactionController(
                with: configuration,
                transaction: transaction,
                completion: completion
            )

            // Present the controller modally
            transactionController.modalPresentationStyle = .fullScreen
            present(transactionController, animated: true)
        } catch {
            // Handle initialization errors (e.g., jailbroken device)
            print("❌ Failed to initialize PayPipes: \(error)")
            presentAlert(
                title: "Initialization Error",
                message: "Unable to initialize PayPipes SDK. Please ensure your device meets the security requirements."
            )
        }
    }

    // MARK: - Helper Methods

    /**
     * Updates the payment button text
     */
    private func updatePaymentButtonText() {
        paymentButton.setTitle("Test Card Payment", for: .normal)
    }

    private func createSwitchRow(title: String, subtitle: String, switchControl: UISwitch) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let rowStack = UIStackView(arrangedSubviews: [textStack, switchControl])
        rowStack.axis = .horizontal
        rowStack.spacing = 16
        rowStack.alignment = .center
        rowStack.distribution = .fill

        return rowStack
    }

    private func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        return divider
    }

    /**
     * Presents an alert with the given title and message
     */
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Theming

    @objc private func customThemeChanged() {
        isCustomThemeEnabled = customThemeSwitch.isOn
        updateTheme()
    }

    private func updateTheme() {
        if !isCustomThemeEnabled {
            appliedTheme = nil
            return
        }

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

        appliedTheme = Theme(colors: colors, fonts: fonts)
    }
}

// MARK: - Constants

private enum Constants {
    static let clientId = "98779e58-ff64-459d-bed8-e7ec423d1a9c"
    static let clientSecret = "Oemmjba7zxVC5RqCa509YkrXVS2pMnx5y8HjCh9W"
    static let companyName = "My company"
    static let termsUrlString = "https://www.paypipes.com"

    static let defaultAmount = "10"
    static let defaultCurrency = "USD"
    static let defaultFirstName = "John"
    static let defaultLastName = "Smith"
    static let defaultEmail = "john.smith@example.com"

    static let sampleAddress = Address(
        street: "123 Main Street",
        city: "New York",
        state: "NY",
        postCode: "10001",
        country: "US"
    )
    static let samplePhone = Phone(number: "730556448", countryCode: "+420")
}
