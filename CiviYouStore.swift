
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class CiviYouStore: ObservableObject {

    // MARK: - Preferences

    @Published var nickname: String {
        didSet {
            UserDefaults.standard.set(
                nickname,
                forKey: "civi.nickname"
            )
        }
    }

    @Published var hasEntered: Bool {
        didSet {
            UserDefaults.standard.set(
                hasEntered,
                forKey: "civi.entered"
            )
        }
    }

    // MARK: - Account Data

    @Published private(set) var savedItems: [SavedItem] = []
    @Published private(set) var progress = LearningProgress()

    @Published private(set) var isSyncing = false
    @Published var syncError: String?

    // MARK: - Civic Content

    let issues = CivicSampleData.issues
    let opportunities = CivicSampleData.opportunities
    let challenges = CivicSampleData.challenges

    // MARK: - Internal State

    private let firestore = FirestoreService.shared

    private var currentUID: String?
    private var session = 0
    private var revision = 0

    private var loadingAccount = false
    private var pendingEdits: [PendingEdit] = []

    private var saveTask: Task<Void, Never>?
    private var saveRunning = false

    private enum PendingEdit {
        case toggle(String, String, SavedItemType)
        case complete(String, Int)
    }

    // MARK: - Initialization

    init() {
        nickname = UserDefaults.standard.string(
            forKey: "civi.nickname"
        ) ?? "Explorer"

        hasEntered = UserDefaults.standard.bool(
            forKey: "civi.entered"
        )

        loadLocalData()
    }

    // MARK: - Storage Keys

    private var storagePrefix: String {
        guard let currentUID else {
            return "civi.guest"
        }

        return "civi.account.\(currentUID)"
    }

    private var dirtyKey: String {
        storagePrefix + ".needsSync"
    }

    private var needsSync: Bool {
        get {
            UserDefaults.standard.bool(
                forKey: dirtyKey
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: dirtyKey
            )
        }
    }

    // MARK: - Local Storage

    private func loadLocalData() {

        let savedKey = storagePrefix + ".saved"
        let progressKey = storagePrefix + ".progress"

        let legacySaved = currentUID == nil
            ? "civi.saved"
            : savedKey

        let legacyProgress = currentUID == nil
            ? "civi.progress"
            : progressKey

        let savedData =
            UserDefaults.standard.data(forKey: savedKey)
            ?? UserDefaults.standard.data(forKey: legacySaved)

        let progressData =
            UserDefaults.standard.data(forKey: progressKey)
            ?? UserDefaults.standard.data(forKey: legacyProgress)

        if let savedData,
           let decoded = try? JSONDecoder().decode(
                [SavedItem].self,
                from: savedData
           ) {
            savedItems = decoded
        } else {
            savedItems = []
        }

        if let progressData,
           let decoded = try? JSONDecoder().decode(
                LearningProgress.self,
                from: progressData
           ) {
            progress = decoded
        } else {
            progress = LearningProgress()
        }
    }

    private func saveLocalData() {

        if let data = try? JSONEncoder().encode(
            savedItems
        ) {
            UserDefaults.standard.set(
                data,
                forKey: storagePrefix + ".saved"
            )
        }

        if let data = try? JSONEncoder().encode(
            progress
        ) {
            UserDefaults.standard.set(
                data,
                forKey: storagePrefix + ".progress"
            )
        }
    }

    private var hasLocalAccountData: Bool {
        guard currentUID != nil else {
            return false
        }

        return UserDefaults.standard.data(
            forKey: storagePrefix + ".saved"
        ) != nil
        || UserDefaults.standard.data(
            forKey: storagePrefix + ".progress"
        ) != nil
    }

    // MARK: - Account Switching

    func switchAccount(to uid: String?) async {

        guard currentUID != uid else {
            return
        }

        let previousSave = saveTask

        session += 1
        let thisSession = session

        currentUID = uid
        revision = 0
        loadingAccount = uid != nil
        pendingEdits = []
        saveRunning = false
        saveTask = nil
        syncError = nil
        isSyncing = uid != nil

        // Immediately switch to the correct local cache.
        loadLocalData()

        // Allow an earlier save to finish before loading.
        await previousSave?.value

        guard session == thisSession else {
            return
        }

        guard let uid else {
            loadingAccount = false
            isSyncing = false
            return
        }

        let locallyDirty = needsSync
        let cachedItems = savedItems
        let cachedProgress = progress
        let cacheExists = hasLocalAccountData

        do {
            let remote = try await firestore
                .loadStateIfPresent(uid: uid)

            guard session == thisSession else {
                return
            }

            if locallyDirty {

                // Preserve edits that failed to upload.
                savedItems = cachedItems
                progress = cachedProgress

            } else if let remote {

                // For clean accounts, cloud data is authoritative.
                savedItems = remote.savedItems
                progress = remote.progress

            } else if cacheExists {

                // Recover a previous local account cache
                // if its cloud document does not exist.
                savedItems = cachedItems
                progress = cachedProgress
                needsSync = true

            } else {

                // Brand-new account.
                savedItems = []
                progress = LearningProgress()
                needsSync = true
            }

            // Replay changes made while loading.
            let edits = pendingEdits
            pendingEdits = []

            for edit in edits {
                apply(edit)
            }

            if !edits.isEmpty {
                revision += 1
                needsSync = true
            }

            loadingAccount = false
            saveLocalData()
            syncError = nil

            if needsSync {
                scheduleSave()
            } else {
                isSyncing = false
            }

        } catch {

            guard session == thisSession else {
                return
            }

            // Keep local data if the network fails.
            loadingAccount = true
            pendingEdits = []

            syncError =
                "Cloud data could not be loaded. " +
                error.localizedDescription

            isSyncing = false
        }
    }

    // MARK: - Bookmark Status

    func isSaved(_ id: String) -> Bool {
        savedItems.contains {
            $0.referenceID == id
        }
    }

    // MARK: - Issue Bookmarks

    func toggleIssue(_ issue: CivicIssue) {
        record(
            .toggle(
                issue.id,
                issue.title,
                .issue
            )
        )
    }

    // MARK: - Opportunity Bookmarks

    func toggleOpportunity(
        _ opportunity: CivicOpportunity
    ) {
        record(
            .toggle(
                opportunity.id,
                opportunity.title,
                .opportunity
            )
        )
    }

    // MARK: - Learning Challenges

    func finishChallenge(
        _ id: String,
        correct: Int
    ) {
        guard !progress.completedChallengeIDs
            .contains(id) else {
            return
        }

        record(
            .complete(id, correct)
        )
    }

    // MARK: - Apply Changes

    private func apply(_ edit: PendingEdit) {

        switch edit {

        case let .toggle(referenceID, title, type):

            if let index = savedItems.firstIndex(
                where: {
                    $0.referenceID == referenceID
                    && $0.type == type
                }
            ) {
                savedItems.remove(at: index)

            } else {
                savedItems.append(
                    SavedItem(
                        id: UUID().uuidString,
                        type: type,
                        referenceID: referenceID,
                        title: title
                    )
                )
            }

        case let .complete(id, correct):

            guard !progress.completedChallengeIDs
                .contains(id) else {
                return
            }

            progress.completedChallengeIDs.append(id)
            progress.totalCorrectAnswers += correct
        }
    }

    private func record(_ edit: PendingEdit) {

        apply(edit)

        if loadingAccount {
            pendingEdits.append(edit)
        }

        persist()
    }

    // MARK: - Save Changes

    private func persist() {

        revision += 1
        saveLocalData()

        guard currentUID != nil else {
            return
        }

        needsSync = true

        if !loadingAccount {
            scheduleSave()
        }
    }

    // MARK: - Cloud Save Queue

    private func scheduleSave() {

        guard let uid = currentUID,
              !loadingAccount,
              !saveRunning,
              needsSync else {
            return
        }

        let thisSession = session

        saveRunning = true
        isSyncing = true

        saveTask = Task {

            while session == thisSession,
                  currentUID == uid,
                  needsSync {

                let itemsSnapshot = savedItems
                let progressSnapshot = progress
                let savedRevision = revision

                do {
                    try await firestore.saveState(
                        uid: uid,
                        savedItems: itemsSnapshot,
                        progress: progressSnapshot
                    )

                    guard session == thisSession,
                          currentUID == uid else {
                        return
                    }

                    syncError = nil

                    if revision == savedRevision {

                        // All known edits were uploaded.
                        needsSync = false

                    } else {

                        // More edits occurred while saving.
                        // Repeat with the latest state.
                        continue
                    }

                } catch {

                    guard session == thisSession,
                          currentUID == uid else {
                        return
                    }

                    // Keep local data marked as unsynced.
                    syncError =
                        "Your changes are saved locally, " +
                        "but cloud sync failed: " +
                        error.localizedDescription

                    break
                }
            }

            guard session == thisSession,
                  currentUID == uid else {
                return
            }

            saveRunning = false
            isSyncing = false
        }
    }

    // MARK: - Manual Retry

    func retrySync() {

        guard currentUID != nil else {
            return
        }

        guard !loadingAccount else {
            return
        }

        scheduleSave()
    }

    // MARK: - Reset Guest Progress

    func resetGuestData() {

        guard currentUID == nil else {
            syncError =
                "Sign out to reset guest data."
            return
        }

        savedItems = []
        progress = LearningProgress()
        nickname = "Explorer"

        // Remove legacy demo storage.
        UserDefaults.standard.removeObject(
            forKey: "civi.saved"
        )

        UserDefaults.standard.removeObject(
            forKey: "civi.progress"
        )

        saveLocalData()
    }
}
