
import SwiftUI
import FirebaseAuth

struct ProfileView: View {

    @EnvironmentObject private var store: CiviYouStore
    @EnvironmentObject private var auth: AuthService

    @State private var showingNicknameEditor = false
    @State private var editedNickname = ""
    @State private var isSavingNickname = false
    @State private var showingResetConfirmation = false
    @State private var profileError: String?

    // MARK: - Account Information

    private var displayName: String {
        if auth.isSignedIn {
            let name = auth.nickname.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            return name.isEmpty ? "Explorer" : name
        }

        let name = store.nickname.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return name.isEmpty ? "Explorer" : name
    }

    private var accountStatus: String {
        auth.isSignedIn
            ? "CiviYou Member"
            : "Guest Explorer"
    }

    // MARK: - Main Screen

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                CiviSectionHeader(
                    title: "Your civic space",
                    subtitle: "Your progress, your interests, your impact."
                )

                profileCard

                statisticsSection

                savedSection

                learningSection

                accountSection

                privacySection
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingNicknameEditor) {
            nicknameEditor
        }
        .alert(
            "Profile update failed",
            isPresented: Binding(
                get: { profileError != nil },
                set: {
                    if !$0 {
                        profileError = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                profileError = nil
            }
        } message: {
            Text(profileError ?? "Please try again.")
        }
        .confirmationDialog(
            "Delete all local guest data?",
            isPresented: $showingResetConfirmation
        ) {
            Button("Delete data", role: .destructive) {
                store.resetGuestData()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "Your guest nickname, bookmarks, and saved progress in the original profile store will be reset."
            )
        }
    }

    // MARK: - Main Profile Card

    private var profileCard: some View {
        CiviCard(color: CiviYouTheme.pink) {
            VStack(alignment: .leading, spacing: 16) {

                HStack(alignment: .center, spacing: 15) {

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 65))
                        .foregroundStyle(CiviYouTheme.charcoal)

                    VStack(alignment: .leading, spacing: 7) {

                        Text(displayName)
                            .font(CiviYouTheme.heading(27))
                            .foregroundStyle(CiviYouTheme.charcoal)

                        CiviPill(
                            title: accountStatus,
                            color: CiviYouTheme.white
                        )
                    }
                }

                if auth.isSignedIn,
                   let email = auth.user?.email {

                    Label(
                        email,
                        systemImage: "envelope"
                    )
                    .font(CiviYouTheme.body(13))
                    .foregroundStyle(
                        CiviYouTheme.charcoal.opacity(0.8)
                    )
                }

                Divider()

                Button {
                    editedNickname = displayName
                    showingNicknameEditor = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "pencil")

                        Text("Edit nickname")
                            .font(.subheadline.bold())

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(CiviYouTheme.charcoal)
                }
                .buttonStyle(.plain)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    // MARK: - Statistics

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            CiviSectionHeader(
                title: "Your progress",
                subtitle: "Keep track of what you've explored."
            )

            HStack(spacing: 12) {

                statisticCard(
                    value: store.savedItems.count,
                    title: "Saved items",
                    symbol: "bookmark.fill",
                    color: CiviYouTheme.blue
                )

                statisticCard(
                    value: store.progress.completedChallengeIDs.count,
                    title: "Challenges",
                    symbol: "checkmark.seal.fill",
                    color: CiviYouTheme.mint
                )
            }

            if store.isSyncing {
                HStack(spacing: 8) {
                    ProgressView()

                    Text("Syncing your progress...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = store.syncError {
                Text("Sync issue: \(error)")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func statisticCard(
        value: Int,
        title: String,
        symbol: String,
        color: Color
    ) -> some View {
        CiviCard(color: color) {
            VStack(alignment: .leading, spacing: 11) {

                Image(systemName: symbol)
                    .font(.system(size: 23))

                Text("\(value)")
                    .font(CiviYouTheme.heading(30))

                Text(title)
                    .font(CiviYouTheme.body(12))
            }
            .foregroundStyle(CiviYouTheme.charcoal)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    // MARK: - Saved Resources

    private var savedSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            CiviSectionHeader(
                title: "Your saved items",
                subtitle: "Return to the issues and opportunities you've bookmarked."
            )

            NavigationLink {
                SavedView()
            } label: {
                CiviCard(
                    color: CiviYouTheme.yellow.opacity(0.65)
                ) {
                    HStack(spacing: 14) {

                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 29))
                            .frame(width: 40)

                        VStack(
                            alignment: .leading,
                            spacing: 7
                        ) {

                            Text("Saved resources")
                                .font(CiviYouTheme.heading(21))

                            Text(
                                "\(store.savedItems.count) saved items"
                            )
                            .font(CiviYouTheme.body(14))

                            Text(
                                "Review saved issues and civic opportunities."
                            )
                            .font(CiviYouTheme.body(12))
                        }

                        Spacer(minLength: 4)

                        Image(systemName: "chevron.right")
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(CiviYouTheme.charcoal)
                }
            }
            .buttonStyle(.plain)

            if store.savedItems.isEmpty {
                Text(
                    "Nothing saved yet? Explore civic issues and opportunities, then tap the bookmark icon to keep them here."
                )
                .font(CiviYouTheme.body(13))
                .foregroundStyle(
                    CiviYouTheme.charcoal.opacity(0.7)
                )
            }
        }
    }

    // MARK: - Learning

    private var learningSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            CiviSectionHeader(title: "Your learning")

            NavigationLink {
                ChallengeListView()
            } label: {
                CiviCard(color: CiviYouTheme.blue.opacity(0.65)) {
                    HStack(spacing: 14) {

                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 29))

                        VStack(
                            alignment: .leading,
                            spacing: 5
                        ) {

                            Text("Civic learning")
                                .font(CiviYouTheme.heading(20))

                            Text(
                                "Your courses, XP, streaks, and lesson history"
                            )
                            .font(CiviYouTheme.body(13))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(CiviYouTheme.charcoal)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Account Settings

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            CiviSectionHeader(
                title: "Account & settings"
            )

            NavigationLink {
                AuthView()
            } label: {
                CiviCard(
                    color: CiviYouTheme.mint.opacity(0.6)
                ) {
                    HStack(spacing: 14) {

                        Image(
                            systemName: auth.isSignedIn
                                ? "person.crop.circle.badge.checkmark"
                                : "person.crop.circle.badge.plus"
                        )
                        .font(.system(size: 28))

                        VStack(
                            alignment: .leading,
                            spacing: 5
                        ) {

                            Text(
                                auth.isSignedIn
                                    ? "Your CiviYou Account"
                                    : "Create an account"
                            )
                            .font(CiviYouTheme.heading(20))

                            Text(
                                auth.isSignedIn
                                    ? "Account information"
                                    : "Sign in to sync supported progress across devices"
                            )
                            .font(CiviYouTheme.body(13))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(CiviYouTheme.charcoal)
                }
            }
            .buttonStyle(.plain)

            if auth.isSignedIn {

                Button {
                    auth.signOut()
                } label: {
                    Label(
                        "Sign out",
                        systemImage: "rectangle.portrait.and.arrow.right"
                    )
                    .font(.subheadline.bold())
                    .foregroundStyle(CiviYouTheme.charcoal)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(15)
                    .background(
                        CiviYouTheme.white,
                        in: RoundedRectangle(
                            cornerRadius: 15
                        )
                    )
                }
                .buttonStyle(.plain)

            } else {

                CiviCard {
                    VStack(
                        alignment: .leading,
                        spacing: 13
                    ) {

                        Label(
                            "Guest mode",
                            systemImage: "iphone"
                        )
                        .font(.subheadline.bold())

                        Text(
                            "Your guest profile and supported progress are stored locally on this device."
                        )
                        .font(CiviYouTheme.body(13))

                        Divider()

                        Button(role: .destructive) {
                            showingResetConfirmation = true
                        } label: {
                            Label(
                                "Reset guest profile",
                                systemImage: "trash"
                            )
                            .font(.subheadline)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Privacy

    private var privacySection: some View {
        CiviCard(
            color: CiviYouTheme.blue.opacity(0.3)
        ) {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                Label(
                    "Your data",
                    systemImage: "lock.shield"
                )
                .font(CiviYouTheme.heading(20))

                Text(
                    auth.isSignedIn
                        ? "Your saved items and original challenge progress can sync with your account. CiviAI conversations, new course history, XP, streaks, and participation records are currently saved on this device."
                        : "Your guest profile, bookmarks, CiviAI conversations, course history, and participation records are stored locally on this device."
                )
                .font(CiviYouTheme.body(13))
            }
            .foregroundStyle(CiviYouTheme.charcoal)
        }
    }

    // MARK: - Edit Nickname

    private var nicknameEditor: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        "Enter your nickname",
                        text: $editedNickname
                    )
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .onChange(of: editedNickname) { _, newValue in
                        if newValue.count > 30 {
                            editedNickname = String(
                                newValue.prefix(30)
                            )
                        }
                    }
                } header: {
                    Text("What should we call you?")
                } footer: {
                    Text(
                        "Your nickname can be up to 30 characters long."
                    )
                }
            }
            .navigationTitle("Edit nickname")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingNicknameEditor = false
                    }
                    .disabled(isSavingNickname)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveNickname()
                    } label: {
                        if isSavingNickname {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(
                        isSavingNickname ||
                        editedNickname.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
    }

    // MARK: - Save Nickname

    private func saveNickname() {
        let newName = String(
            editedNickname.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).prefix(30)
        )

        guard !newName.isEmpty else {
            return
        }

        if auth.isSignedIn {

            isSavingNickname = true

            Task {
                let success = await auth.updateNickname(
                    newName
                )

                isSavingNickname = false

                if success {
                    showingNicknameEditor = false
                } else {
                    profileError = auth.errorMessage
                        ?? "Your nickname could not be saved."
                }
            }

        } else {

            store.nickname = newName
            showingNicknameEditor = false
        }
    }
}
