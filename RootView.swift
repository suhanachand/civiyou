
import SwiftUI

// MARK: - App Navigation

enum CiviTab: String, CaseIterable {
    case home = "Home"
    case explore = "Explore"
    case participate = "Act"
    case ai = "CiviAI"
    case profile = "Profile"

    var symbol: String {
        switch self {
        case .home:
            return "house.fill"
        case .explore:
            return "safari.fill"
        case .participate:
            return "megaphone.fill"
        case .ai:
            return "sparkles"
        case .profile:
            return "person.crop.circle.fill"
        }
    }
}

// MARK: - Root View

struct RootView: View {

    @EnvironmentObject private var store: CiviYouStore

    @State private var selectedTab: CiviTab = .home

    var body: some View {
        Group {
            if store.hasEntered {
                mainInterface
            } else {
                welcome
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Main App

    private var mainInterface: some View {
        VStack(spacing: 0) {

            Group {
                switch selectedTab {
                case .home:
                    NavigationStack {
                        HomeView(selectedTab: $selectedTab)
                    }

                case .explore:
                    NavigationStack {
                        ExploreView()
                    }

                case .participate:
                    NavigationStack {
                        ParticipateView()
                    }

                case .ai:
                    NavigationStack {
                        CivicAIView()
                    }

                case .profile:
                    NavigationStack {
                        ProfileView()
                    }
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )

            tabBar
        }
        .background(CiviYouTheme.cream)
    }

    // MARK: - Bottom Navigation

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(CiviTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 5) {

                        Image(systemName: tab.symbol)
                            .font(
                                .system(
                                    size: 19,
                                    weight: .semibold
                                )
                            )

                        Text(tab.rawValue)
                            .font(
                                .system(
                                    size: 10,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(
                        selectedTab == tab
                            ? CiviYouTheme.charcoal
                            : .gray
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(
                                cornerRadius: 14
                            )
                            .fill(
                                CiviYouTheme.yellow.opacity(0.38)
                            )
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(
                    selectedTab == tab
                        ? .isSelected
                        : []
                )
            }
        }
        .padding(.horizontal, 5)
        .padding(.top, 8)
        .background(CiviYouTheme.white)
    }

    // MARK: - Welcome Screen

    private var welcome: some View {
        VStack(spacing: 25) {

            Spacer()

            Image(
                systemName: "building.columns.circle.fill"
            )
            .font(.system(size: 100))
            .foregroundStyle(CiviYouTheme.charcoal)
            .padding(30)
            .background(
                CiviYouTheme.yellow,
                in: RoundedRectangle(cornerRadius: 42)
            )
            .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text("CiviYou")
                    .font(CiviYouTheme.heading(48))

                Text("Understand. Connect. Participate.")
                    .font(CiviYouTheme.body(17))

                Text(
                    "Your community. Your curiosity. Your future."
                )
                .font(CiviYouTheme.body(15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            Spacer()

            CiviPrimaryButton(
                title: "Get Started",
                symbol: "arrow.right"
            ) {
                store.hasEntered = true
            }

            Text("Explore CiviYou as a guest")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(
                "Educational examples are not live government updates."
            )
            .font(.caption2)
            .foregroundStyle(.secondary)

            Spacer().frame(height: 15)
        }
        .padding(28)
        .foregroundStyle(CiviYouTheme.charcoal)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(CiviYouTheme.cream)
    }
}
