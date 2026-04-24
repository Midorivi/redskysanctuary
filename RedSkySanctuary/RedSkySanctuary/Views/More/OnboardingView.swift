import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                skipButton

                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    featuresPage.tag(1)
                    getStartedPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(.snappy), value: currentPage)

                pageIndicator
                    .padding(.bottom, 32)

                bottomButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
    }

    private var skipButton: some View {
        HStack {
            Spacer()
            if currentPage < 2 {
                Button("Skip") {
                    completeOnboarding()
                }
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .transition(.opacity)
            }
        }
        .frame(height: 44)
        .animation(.spring(.snappy), value: currentPage)
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sun.max.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.pulse.byLayer, options: .repeating)

            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("Red Sky Sanctuary")
                    .font(.system(.largeTitle, design: .rounded).bold())
            }

            Text("Care, track, and protect every animal\nin your sanctuary.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }

    private var featuresPage: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Track Your Animals")
                .font(.system(.title2, design: .rounded).bold())

            VStack(alignment: .leading, spacing: 20) {
                featureRow(
                    icon: "pawprint.fill",
                    color: .blue,
                    title: "Animal Profiles",
                    subtitle: "Health records, photos & history"
                )
                featureRow(
                    icon: "checklist",
                    color: .green,
                    title: "Daily Tasks",
                    subtitle: "Feeding, cleaning & care routines"
                )
                featureRow(
                    icon: "bell.badge.fill",
                    color: .purple,
                    title: "Reminders",
                    subtitle: "Vet visits, medications & more"
                )
                featureRow(
                    icon: "shippingbox.fill",
                    color: .orange,
                    title: "Supplies",
                    subtitle: "Inventory & expense tracking"
                )
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }

    private var getStartedPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 64))
                .foregroundStyle(.pink)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce, options: .repeating.speed(0.5))

            VStack(spacing: 12) {
                Text("Get Started")
                    .font(.system(.title2, design: .rounded).bold())
                Text("Add your first animal and begin\ntracking their care today.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.blue : Color(.systemGray4))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(.snappy), value: currentPage)
            }
        }
        .padding(.top, 16)
    }

    private var bottomButton: some View {
        Group {
            if currentPage < 2 {
                Button {
                    withAnimation(.spring(.snappy)) {
                        currentPage += 1
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14, style: .continuous))
                }
                .sensoryFeedback(.impact, trigger: currentPage)
            } else {
                Button {
                    completeOnboarding()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14, style: .continuous))
                }
                .sensoryFeedback(.success, trigger: hasCompletedOnboarding)
            }
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }
}

#Preview {
    OnboardingView()
}
