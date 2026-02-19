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
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                
                // Current step view
                currentStepView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                // Navigation buttons
                navigationButtons
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Setting up your account...")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .onChange(of: viewModel.didCompleteOnboarding) { _, didComplete in
            if didComplete {
                onCompleted()
            }
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Current Step View
    
    @ViewBuilder
    private var currentStepView: some View {
        ScrollView {
            VStack(spacing: 20) {
                switch viewModel.currentStep {
                case .welcome:
                    WelcomeStepView()
                case .personalInfo:
                    PersonalInfoStepView(viewModel: viewModel)
                case .categories:
                    CategoriesStepView(viewModel: viewModel)
                case .accounts:
                    AccountsStepView(viewModel: viewModel)
                case .security:
                    SecurityStepView(viewModel: viewModel)
                }
            }
            .padding()
        }
        .animation(.easeInOut, value: viewModel.currentStep)
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button (hidden on first step)
            if viewModel.currentStep != .welcome {
                Button {
                    withAnimation {
                        viewModel.previousStep()
                    }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            
            // Next/Complete button
            Button {
                withAnimation {
                    viewModel.nextStep()
                }
            } label: {
                HStack {
                    Text(viewModel.currentStep == .security ? "Complete" : "Continue")
                        .fontWeight(.semibold)
                    
                    if viewModel.currentStep != .security {
                        Image(systemName: "chevron.right")
                    } else {
                        Image(systemName: "checkmark")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(context: PersistenceController.shared.container.viewContext)
}
