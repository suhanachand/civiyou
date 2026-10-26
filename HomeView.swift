
import SwiftUI
import FirebaseAuth

struct HomeView: View {

    @EnvironmentObject private var store: CiviYouStore
    @EnvironmentObject private var auth: AuthService

    @Binding var selectedTab: CiviTab

    // Shared with ExploreView to open
    // the correct section directly.
    @AppStorage("civi.explore.section")
    private var exploreSection = 0

    private var displayName: String {
        let name = auth.isSignedIn
            ? auth.nickname
            : store.nickname

        let trimmed = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? "Explorer" : trimmed
    }

    private var greeting: String {
        let hour = Calendar.current.component(
            .hour,
            from: Date()
        )

        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }

    // Rotates the featured issue once per
    // local calendar day.
    private var dailyIssue: CivicIssue? {
        guard !store.issues.isEmpty else {
            return nil
        }

        let day = Calendar.current.ordinality(
            of: .day,
            in: .era,
            for: Date()
        ) ?? 0

        let index = day % store.issues.count

        return store.issues[index]
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 23
            ) {
                header

                welcomeCard

                journeySection

                dailyIssueSection

                moreIssuesSection

                learningSection

                communitySection

                dailyTipSection
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {

            VStack(alignment: .leading, spacing: 5) {

                Text(greeting)
                    .font(CiviYouTheme.body(15))
                    .foregroundStyle(.secondary)

                Text(displayName + "!")
                    .font(CiviYouTheme.heading(31))
                    .foregroundStyle(CiviYouTheme.charcoal)

                Text(
                    Date().formatted(
                        .dateTime
                            .weekday(.wide)
                            .month(.wide)
                            .day()
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                selectedTab = .profile
            } label: {
                Image(
                    systemName: "person.crop.circle.fill"
                )
                .font(.system(size: 44))
                .foregroundStyle(CiviYouTheme.charcoal)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open profile")
        }
    }

    // MARK: - Welcome

    private var welcomeCard: some View {
        CiviCard(color: CiviYouTheme.yellow) {
            VStack(
                alignment: .leading,
                spacing: 13
            ) {

                Image(
                    systemName: "sparkles.rectangle.stack.fill"
                )
                .font(.system(size: 35))

                Text("Your community.\nYour voice. Your impact.")
                    .font(CiviYouTheme.heading(29))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(
                    "Learn how the world around you works, connect with other young people, and take meaningful action."
                )
                .font(CiviYouTheme.body(15))

                Button {
                    openExplore(0)
                } label: {
                    Label(
                        "Start exploring",
                        systemImage: "arrow.right"
                    )
                    .font(.subheadline.bold())
                    .foregroundStyle(CiviYouTheme.charcoal)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        CiviYouTheme.white,
                        in: RoundedRectangle(
                            cornerRadius: 13
                        )
                    )
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(CiviYouTheme.charcoal)
        }
    }

    // MARK: - Your Civic Journey

    private var journeySection: some View {
        VStack(
            alignment: .leading,
            spacing: 13
        ) {

            CiviSectionHeader(
                title: "Your civic journey",
                subtitle: "Three ways to make a difference."
            )

            // LEARN -> Explore / Learn
            journeyButton(
                title: "Learn",
                subtitle: "Explore courses, guides, and civic knowledge.",
                symbol: "book.closed.fill",
                color: CiviYouTheme.blue
            ) {
                openExplore(0)
            }

            // CONNECT -> Explore / Voices
            journeyButton(
                title: "Connect",
                subtitle: "Share your ideas and join youth discussions.",
                symbol: "bubble.left.and.bubble.right.fill",
                color: CiviYouTheme.mint
            ) {
                openExplore(2)
            }

            // PARTICIPATE -> Act
            journeyButton(
                title: "Participate",
                subtitle: "Find opportunities and take action in your community.",
                symbol: "megaphone.fill",
                color: CiviYouTheme.pink
            ) {
                selectedTab = .participate
            }
        }
    }

    private func journeyButton(
        title: String,
        subtitle: String,
        symbol: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            CiviCard(color: color) {
                HStack(spacing: 15) {

                    Image(systemName: symbol)
                        .font(.system(size: 27))
                        .frame(width: 42)

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {
                        Text(title)
                            .font(CiviYouTheme.heading(23))

                        Text(subtitle)
                            .font(CiviYouTheme.body(13))
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 4)

                    Image(
                        systemName: "arrow.up.right"
                    )
                    .font(.headline)
                }
                .foregroundStyle(CiviYouTheme.charcoal)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Daily Civic Issue

    private var dailyIssueSection: some View {
        VStack(
            alignment: .leading,
            spacing: 13
        ) {

            CiviSectionHeader(
                title: "Today's civic spotlight",
                subtitle: "One issue to understand today."
            )

            if let issue = dailyIssue {

                NavigationLink {
                    IssueDetailView(issue: issue)
                } label: {
                    CiviCard(color: CiviYouTheme.blue) {
                        VStack(
                            alignment: .leading,
                            spacing: 14
                        ) {

                            HStack {
                                Image(
                                    systemName: issue.symbol
                                )
                                .font(.system(size: 33))

                                Spacer()

                                CiviPill(
                                    title: "Daily spotlight",
                                    color: CiviYouTheme.white
                                )
                            }

                            Text(issue.title)
                                .font(CiviYouTheme.heading(25))

                            Text(issue.summary)
                                .font(CiviYouTheme.body(15))
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )

                            HStack {
                                Label(
                                    issue.category,
                                    systemImage: "tag"
                                )

                                Spacer()

                                Image(
                                    systemName: "arrow.right"
                                )
                            }
                            .font(.caption.bold())
                        }
                        .foregroundStyle(CiviYouTheme.charcoal)
                    }
                }
                .buttonStyle(.plain)

                Text(
                    "Featured from CiviYou's civic issue library. The topic changes daily; it is not a live news headline."
                )
                .font(.caption)
                .foregroundStyle(.secondary)

            } else {

                CiviCard {
                    Text(
                        "Civic spotlight topics will appear here when issues are available."
                    )
                    .font(CiviYouTheme.body(14))
                }
            }
        }
    }

    // MARK: - More Civic Issues

    private var moreIssuesSection: some View {
        VStack(
            alignment: .leading,
            spacing: 13
        ) {

            CiviSectionHeader(
                title: "Issues shaping our world",
                subtitle: "Discover the facts and decisions behind important topics."
            )

            if store.issues.isEmpty {
                Text("No civic issues are available yet.")
                    .font(CiviYouTheme.body(14))
                    .foregroundStyle(.secondary)
            } else {

                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    HStack(
                        alignment: .top,
                        spacing: 12
                    ) {

                        ForEach(store.issues) { issue in

                            NavigationLink {
                                IssueDetailView(issue: issue)
                            } label: {
                                issueCard(issue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }

                Text(
                    "Explore an issue to see its background, key facts, government responsibilities, and sources."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func issueCard(
        _ issue: CivicIssue
    ) -> some View {
        CiviCard(
            color: CiviYouTheme.white
        ) {
            VStack(
                alignment: .leading,
                spacing: 11
            ) {

                Image(systemName: issue.symbol)
                    .font(.system(size: 27))
                    .foregroundStyle(
                        CiviYouTheme.charcoal
                    )

                Text(issue.category.uppercased())
                    .font(.system(
                        size: 10,
                        weight: .bold
                    ))
                    .foregroundStyle(.secondary)

                Text(issue.title)
                    .font(CiviYouTheme.heading(19))
                    .lineLimit(2)

                Text(issue.summary)
                    .font(CiviYouTheme.body(13))
                    .lineLimit(3)

                Spacer(minLength: 4)

                Label(
                    "Explore issue",
                    systemImage: "arrow.right"
                )
                .font(.caption.bold())
            }
            .foregroundStyle(CiviYouTheme.charcoal)
            .frame(
                width: 220,
                height: 225,
                alignment: .topLeading
            )
        }
    }

    // MARK: - Learning

    private var learningSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            CiviSectionHeader(
                title: "Keep learning",
                subtitle: "Build your knowledge one lesson at a time."
            )

            NavigationLink {
                ChallengeListView()
            } label: {
                CiviCard(
                    color: CiviYouTheme.yellow
                ) {
                    HStack(spacing: 14) {

                        Image(
                            systemName: "brain.head.profile"
                        )
                        .font(.system(size: 32))

                        VStack(
                            alignment: .leading,
                            spacing: 7
                        ) {
                            Text("Civic Learning Academy")
                                .font(CiviYouTheme.heading(21))

                            Text(
                                "Adaptive lessons, XP, streaks, and saved learning history."
                            )
                            .font(CiviYouTheme.body(13))
                        }

                        Spacer(minLength: 0)

                        Image(
                            systemName: "chevron.right"
                        )
                    }
                    .foregroundStyle(
                        CiviYouTheme.charcoal
                    )
                }
            }
            .buttonStyle(.plain)

            Button {
                openExplore(0)
            } label: {
                Label(
                    "Browse educational guides",
                    systemImage: "book"
                )
                .font(.subheadline.bold())
                .foregroundStyle(
                    CiviYouTheme.charcoal
                )
                .padding(13)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Community

    private var communitySection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            CiviSectionHeader(
                title: "Get involved",
                subtitle: "Put what you've learned into practice."
            )

            CiviCard(
                color: CiviYouTheme.pink.opacity(0.65)
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {

                    Image(
                        systemName: "hands.sparkles"
                    )
                    .font(.system(size: 31))

                    Text("Make an impact near you")
                        .font(CiviYouTheme.heading(23))

                    Text(
                        "Find Arizona volunteer programs, youth leadership opportunities, and community projects."
                    )
                    .font(CiviYouTheme.body(14))

                    CiviPrimaryButton(
                        title: "Take action",
                        symbol: "arrow.right"
                    ) {
                        selectedTab = .participate
                    }
                }
                .foregroundStyle(
                    CiviYouTheme.charcoal
                )
            }
        }
    }

    // MARK: - Daily Tip

    private var dailyTipSection: some View {
        CiviCard(
            color: CiviYouTheme.mint.opacity(0.45)
        ) {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                Label(
                    "A little civic knowledge",
                    systemImage: "lightbulb.fill"
                )
                .font(CiviYouTheme.heading(20))

                Text(
                    "You don't have to be old enough to vote to contribute to your community. You can learn about issues, volunteer, join youth programs, and share ideas at appropriate public meetings."
                )
                .font(CiviYouTheme.body(14))
            }
            .foregroundStyle(
                CiviYouTheme.charcoal
            )
        }
    }

    // MARK: - Navigation Helper

    private func openExplore(_ section: Int) {
        exploreSection = section
        selectedTab = .explore
    }
}
