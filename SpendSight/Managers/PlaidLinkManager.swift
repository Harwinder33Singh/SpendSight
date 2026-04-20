//
//  PlaidLinkManager.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/15/26.
//

import SwiftUI
import LinkKit
import Combine

// MARK: - Result Model

struct PlaidLinkResult {
    let publicToken: String
    let institutionName: String?
    let institutionId: String?
}

// MARK: - PlaidLinkManager

@MainActor
class PlaidLinkManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var connectedInstitutionName: String?
    @Published var didConnectBank = false

    private var handler: Handler?
    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    // MARK: - Start Plaid Link

    func startLink(from viewController: UIViewController) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Get link token from our backend
                let linkToken = try await PlaidService.shared.createLinkToken(userId: userId)

                // Configure Plaid Link
                var linkConfiguration = LinkTokenConfiguration(
                    token: linkToken,
                    onSuccess: { [weak self] success in
                        Task { @MainActor in
                            await self?.handleSuccess(
                                publicToken: success.publicToken,
                                metadata: success.metadata
                            )
                        }
                    }
                )

                linkConfiguration.onExit = { [weak self] exit in
                    Task { @MainActor in
                        self?.isLoading = false
                        if let error = exit.error {
                            self?.showError(message: error.displayMessage ?? "Bank connection cancelled")
                        }
                    }
                }

                let result = Plaid.create(linkConfiguration)

                switch result {
                case .failure(let error):
                    isLoading = false
                    showError(message: error.localizedDescription)
                case .success(let handler):
                    self.handler = handler
                    isLoading = false
                    handler.open(presentUsing: .viewController(viewController))
                }

            } catch {
                isLoading = false
                showError(message: error.localizedDescription)
            }
        }
    }

    // MARK: - Handle Success

    private func handleSuccess(publicToken: String, metadata: SuccessMetadata) async {
        isLoading = true

        do {
            let response = try await PlaidService.shared.exchangePublicToken(
                publicToken: publicToken,
                userId: userId
            )

            connectedInstitutionName = response.institutionName
            didConnectBank = true
            isLoading = false

        } catch {
            isLoading = false
            showError(message: error.localizedDescription)
        }
    }

    // MARK: - Error Handling

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - SwiftUI Wrapper

struct PlaidLinkButton: View {
    @StateObject private var manager: PlaidLinkManager
    let onSuccess: (String) -> Void

    init(userId: String, onSuccess: @escaping (String) -> Void) {
        _manager = StateObject(wrappedValue: PlaidLinkManager(userId: userId))
        self.onSuccess = onSuccess
    }

    var body: some View {
        Button {
            guard let viewController = topMostViewController() else { return }
            manager.startLink(from: viewController)
        } label: {
            HStack {
                if manager.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "building.columns.fill")
                    Text("Connect Bank Account")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(manager.isLoading)
        .alert("Error", isPresented: $manager.showError) {
            Button("OK") { }
        } message: {
            Text(manager.errorMessage ?? "Something went wrong")
        }
        .onChange(of: manager.didConnectBank) { _, connected in
            if connected, let name = manager.connectedInstitutionName {
                onSuccess(name)
            }
        }
    }

    // MARK: - Find topmost presented view controller

    private func topMostViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let root = window.rootViewController else {
            return nil
        }
        return findTopViewController(from: root)
    }

    private func findTopViewController(from vc: UIViewController) -> UIViewController {
        if let presented = vc.presentedViewController {
            return findTopViewController(from: presented)
        }
        if let nav = vc as? UINavigationController,
           let top = nav.topViewController {
            return findTopViewController(from: top)
        }
        if let tab = vc as? UITabBarController,
           let selected = tab.selectedViewController {
            return findTopViewController(from: selected)
        }
        return vc
    }
}
