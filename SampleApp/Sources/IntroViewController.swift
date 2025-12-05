//
//  IntroViewController.swift
//  ExampleApp
//
//  Copyright © 2025 Purple Next s.r.o. All rights reserved.
//

import SwiftUI
import UIKit

/// An intro screen that lets you choose between the UIKit and SwiftUI samples.
/// - UIKit sample presents the classic `ViewController` demonstrating imperative integration.
/// - SwiftUI sample presents `SwiftUISampleView` using the `.payPipesUI` modifier.
final class IntroViewController: UIViewController {
    // MARK: - Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "PayPipes Examples"
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Private

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose UI Technology"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var uikitButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "UIKit Sample"
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 12
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(openUIKitSample), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var swiftUIButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "SwiftUI Sample"
        configuration.baseBackgroundColor = .systemGreen
        configuration.baseForegroundColor = .white
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 12
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(openSwiftUISample), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, uikitButton, swiftUIButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    @objc private func openUIKitSample() {
        navigationController?.pushViewController(ViewController(), animated: true)
    }

    @objc private func openSwiftUISample() {
        let swiftUIView = SwiftUISampleView()
        let hosting = UIHostingController(rootView: swiftUIView)
        navigationController?.pushViewController(hosting, animated: true)
    }
}
