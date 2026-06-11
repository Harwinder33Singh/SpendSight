//
//  OnboardingView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/18/26.
//

import SwiftUI
import CoreData

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    let onCompleted: () -> Void

    init(context: NSManagedObjectContext, onCompleted: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(context: context))
        self.onCompleted = onCompleted
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color(.systemBackground).ignoresSafeArea()

            // Step content
            VStack(spacing: 0) {
                // Step dots
                stepDots
                    .padding(.top, 20)

                // Current step
                currentStepView
            }

            // Navigation buttons pinned to bottom
            navigationButtons
                .background(.ultraThinMaterial)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        Text("Setting up your account…")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .onChange(of: viewModel.didCompleteOnboarding) { _, didComplete in
            if didComplete { onCompleted() }
        }
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step == viewModel.currentStep
                          ? Color.accentColor
                          : step.rawValue < viewModel.currentStep.rawValue
                            ? Color.accentColor.opacity(0.4)
                            : Color(.systemGray4))
                    .frame(width: step == viewModel.currentStep ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: viewModel.currentStep)
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Current Step

    @ViewBuilder
    private var currentStepView: some View {
        ZStack {
            switch viewModel.currentStep {
            case .welcome:
                WelcomeStepView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .categories:
                CategoriesStepView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .accounts:
                AccountsStepView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .security:
                SecurityStepView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if viewModel.currentStep != .welcome {
                Button {
                    withAnimation { viewModel.previousStep() }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .frame(width: 52, height: 52)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .foregroundStyle(.primary)
            }

            Button {
                withAnimation { viewModel.nextStep() }
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.currentStep == .security ? "Get Started" : "Continue")
                        .fontWeight(.semibold)
                    Image(systemName: viewModel.currentStep == .security ? "checkmark" : "arrow.right")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(viewModel.isLoading ? Color.accentColor.opacity(0.5) : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

#Preview {
    OnboardingView(context: PersistenceController.shared.container.viewContext)
}
