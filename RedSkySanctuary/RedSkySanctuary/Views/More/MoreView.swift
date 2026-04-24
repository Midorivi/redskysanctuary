import SwiftData
import SwiftUI

struct MoreView: View {
    @Environment(CloudKitManager.self) private var cloudKitManager
    @Environment(\.modelContext) private var modelContext
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @State private var shareError: String?
    @State private var showShareError = false
    @State private var isCreatingShare = false

    var body: some View {
        List {
            sanctuarySection
            featuresSection
            settingsSection
            aboutSection
            teamSection
        }
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.large)
        .alert("Sharing Error", isPresented: $showShareError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(shareError ?? "Could not create share link.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
    }

    // MARK: - Sanctuary Header

    private var sanctuarySection: some View {
        Section {
            HStack(spacing: 14) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.orange)
                    .symbolRenderingMode(.hierarchical)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Red Sky Sanctuary")
                        .font(.system(.title3, design: .rounded).bold())
                    Text("Animal care & management")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        Section("Features") {
            NavigationLink {
                EmergencyView()
            } label: {
                moreRow(
                    icon: "cross.case.fill",
                    color: .red,
                    title: "Emergency",
                    subtitle: "Contacts & protocols"
                )
            }

            NavigationLink {
                RemindersListView()
            } label: {
                moreRow(
                    icon: "bell.badge.fill",
                    color: .purple,
                    title: "Reminders",
                    subtitle: "Scheduled notifications"
                )
            }

            NavigationLink {
                SearchView()
            } label: {
                moreRow(
                    icon: "magnifyingglass",
                    color: .blue,
                    title: "Search",
                    subtitle: "Find animals, records & more"
                )
            }
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        Section("Settings") {
            NavigationLink {
                SettingsView()
            } label: {
                moreRow(
                    icon: "gearshape.fill",
                    color: .secondary,
                    title: "Settings",
                    subtitle: "Notifications, data & appearance"
                )
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Inspired by Medwyn's Valley")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Named after our horses Red & Sky")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Team

    private var teamSection: some View {
        Section("Team") {
            Button {
                inviteTeamMember()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.title3)
                        .foregroundStyle(.green)
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Invite Team Member")
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text("Requires paid Apple Developer account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if isCreatingShare {
                        ProgressView()
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
            .disabled(true)
            .sensoryFeedback(.impact, trigger: showShareSheet)
        }
    }

    // MARK: - Row Helper

    private func moreRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Invite

    private func inviteTeamMember() {
        isCreatingShare = true

        Task {
            do {
                let container = modelContext.container
                let share = try await cloudKitManager.createShare(for: container)
                if let url = share.url {
                    shareURL = url
                    showShareSheet = true
                }
            } catch {
                shareError = error.localizedDescription
                showShareError = true
            }
            isCreatingShare = false
        }
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        MoreView()
            .environment(CloudKitManager())
    }
}
