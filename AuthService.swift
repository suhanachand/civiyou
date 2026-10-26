//
//  AuthService.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthService: ObservableObject {

    @Published private(set) var user: FirebaseAuth.User?
    @Published private(set) var nickname = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var listener: AuthStateDidChangeListenerHandle?

    var isSignedIn: Bool {
        user != nil
    }

    init() {
        listener = Auth.auth().addStateDidChangeListener {
            [weak self] _, firebaseUser in

            Task { @MainActor in
                guard let self else { return }

                self.user = firebaseUser

                if let firebaseUser {
                    await self.loadProfile(uid: firebaseUser.uid)
                } else {
                    self.nickname = ""
                }
            }
        }
    }

    // MARK: - Create Account

    func signUp(
        name: String,
        email: String,
        password: String
    ) async -> Bool {

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )

            let safeName = String(
                name.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).prefix(30)
            )

            try await Firestore.firestore()
                .collection("users")
                .document(result.user.uid)
                .setData([
                    "nickname": safeName,
                    "createdAt": FieldValue.serverTimestamp()
                ])

            nickname = safeName
            user = result.user

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Log In

    func signIn(
        email: String,
        password: String
    ) async -> Bool {

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )

            user = result.user
            await loadProfile(uid: result.user.uid)

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Log Out

    func signOut() {
        do {
            try Auth.auth().signOut()

            user = nil
            nickname = ""
            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async -> Bool {

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await Auth.auth().sendPasswordReset(
                withEmail: email
            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Update Nickname

    func updateNickname(_ name: String) async -> Bool {

        guard let uid = user?.uid else {
            errorMessage = "You need to log in first."
            return false
        }

        let safeName = String(
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).prefix(30)
        )

        guard !safeName.isEmpty else {
            errorMessage = "Please enter a nickname."
            return false
        }

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(
                    ["nickname": safeName],
                    merge: true
                )

            nickname = safeName
            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Load User Profile

    private func loadProfile(uid: String) async {

        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()

            if user?.uid == uid {
                nickname = snapshot.data()?["nickname"] as? String
                    ?? "Explorer"
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

