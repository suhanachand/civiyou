
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct CiviYouCloudState {
    let savedItems: [SavedItem]
    let progress: LearningProgress
}

enum FirestoreServiceError: LocalizedError {
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to sync your data."
        }
    }
}

final class FirestoreService {

    static let shared = FirestoreService()

    private let database = Firestore.firestore()

    private init() {}

    // MARK: - Database Reference

    private func stateDocument(
        for uid: String
    ) -> DocumentReference {

        database
            .collection("users")
            .document(uid)
            .collection("privateData")
            .document("appState")
    }

    // MARK: - Authentication Check

    private func verifyUser(_ uid: String) throws {
        guard Auth.auth().currentUser?.uid == uid else {
            throw FirestoreServiceError.notAuthenticated
        }
    }

    // MARK: - Save Account State

    func saveState(
        uid: String,
        savedItems: [SavedItem],
        progress: LearningProgress
    ) async throws {

        try verifyUser(uid)

        let itemsData = try JSONEncoder().encode(savedItems)
        let progressData = try JSONEncoder().encode(progress)

        let itemsObject = try JSONSerialization.jsonObject(
            with: itemsData
        )

        let progressObject = try JSONSerialization.jsonObject(
            with: progressData
        )

        try await stateDocument(for: uid).setData([
            "savedItems": itemsObject,
            "progress": progressObject,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    // MARK: - Load Existing State

    func loadStateIfPresent(
        uid: String
    ) async throws -> CiviYouCloudState? {

        try verifyUser(uid)

        let snapshot = try await stateDocument(
            for: uid
        ).getDocument(source: .server)

        guard snapshot.exists else {
            return nil
        }

        guard let data = snapshot.data() else {
            throw CocoaError(.coderReadCorrupt)
        }

        guard let rawItems = data["savedItems"],
              let rawProgress = data["progress"] else {
            throw CocoaError(.coderReadCorrupt)
        }

        let itemsData = try JSONSerialization.data(
            withJSONObject: rawItems
        )

        let progressData = try JSONSerialization.data(
            withJSONObject: rawProgress
        )

        let items = try JSONDecoder().decode(
            [SavedItem].self,
            from: itemsData
        )

        let progress = try JSONDecoder().decode(
            LearningProgress.self,
            from: progressData
        )

        return CiviYouCloudState(
            savedItems: items,
            progress: progress
        )
    }

    // MARK: - Compatibility

    func loadState(
        uid: String
    ) async throws -> (
        savedItems: [SavedItem],
        progress: LearningProgress
    ) {

        if let state = try await loadStateIfPresent(
            uid: uid
        ) {
            return (state.savedItems, state.progress)
        }

        return ([], LearningProgress())
    }

    // MARK: - Delete Account State

    func deleteState(uid: String) async throws {

        try verifyUser(uid)

        try await stateDocument(for: uid).delete()
    }
}
