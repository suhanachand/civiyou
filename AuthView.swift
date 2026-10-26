
import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var creatingAccount = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var showPassword = false
    @State private var isEligible = false
    @State private var statusMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 56))
                    .foregroundStyle(CiviYouTheme.charcoal)

                Text(auth.isSignedIn
                     ? "Your CiviYou Account"
                     : creatingAccount
                        ? "Join CiviYou"
                        : "Welcome back")
                    .font(CiviYouTheme.heading(30))

                if auth.isSignedIn {
                    signedInContent
                } else {
                    authenticationForm
                }

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(CiviYouTheme.body(14))
                        .foregroundStyle(CiviYouTheme.charcoal)
                }

                if let error = auth.errorMessage {
                    Text(error)
                        .font(CiviYouTheme.body(13))
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }
            }
            .padding(22)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var signedInContent: some View {
        VStack(alignment: .leading, spacing: 15) {
            CiviCard(color: CiviYouTheme.mint.opacity(0.5)) {
                VStack(alignment: .leading, spacing: 10) {
                    Label(
                        "Signed in",
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(.headline)

                    Text(auth.nickname.isEmpty
                         ? "Explorer"
                         : auth.nickname)
                        .font(CiviYouTheme.heading(26))

                    Text(auth.user?.email ?? "")
                        .font(CiviYouTheme.body(14))
                }
            }

            Text("Your account is authenticated with Firebase. Cloud bookmark and learning-progress synchronization will be added next.")
                .font(CiviYouTheme.body(14))
                .foregroundStyle(.secondary)

            CiviPrimaryButton(
                title: "Log Out",
                symbol: "rectangle.portrait.and.arrow.right"
            ) {
                auth.signOut()
            }
        }
    }

    private var authenticationForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            if creatingAccount {
                TextField("Display name", text: $name)
                    .textContentType(.nickname)
                    .modifier(AuthFieldStyle())
            }

            TextField("Email address", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(AuthFieldStyle())

            passwordField("Password", value: $password)

            if creatingAccount {
                passwordField(
                    "Confirm password",
                    value: $confirmation
                )

                Toggle(
                    "I confirm I am at least 13 years old",
                    isOn: $isEligible
                )
                .font(CiviYouTheme.body(13))
                .tint(CiviYouTheme.mint)

                Text("Account creation is currently for private testing only. Public registration requires a completed privacy policy and age-appropriate safeguards.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                showPassword.toggle()
            } label: {
                Label(
                    showPassword ? "Hide password" : "Show password",
                    systemImage: showPassword ? "eye.slash" : "eye"
                )
                .font(.subheadline)
            }

            Button {
                Task {
                    await submit()
                }
            } label: {
                HStack {
                    Spacer()

                    if auth.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(
                            creatingAccount
                            ? "Create Account"
                            : "Log In"
                        )
                    }

                    Spacer()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(16)
                .background(
                    CiviYouTheme.charcoal,
                    in: RoundedRectangle(cornerRadius: 18)
                )
            }
            .disabled(auth.isLoading)

            if !creatingAccount {
                Button("Forgot password?") {
                    Task {
                        guard email.contains("@") else {
                            statusMessage = "Enter your email address first."
                            return
                        }

                        let success = await auth.resetPassword(
                            email: email
                        )

                        if success {
                            statusMessage = "If the address has an eligible account, check the inbox for password-reset instructions."
                        }
                    }
                }
                .font(.subheadline.bold())
            }

            Button(
                creatingAccount
                ? "Already have an account? Log in"
                : "New here? Create an account"
            ) {
                creatingAccount.toggle()
                statusMessage = ""
            }
            .font(CiviYouTheme.body(14))
            .padding(.top, 8)
        }
    }

    private func passwordField(
        _ title: String,
        value: Binding<String>
    ) -> some View {
        Group {
            if showPassword {
                TextField(title, text: value)
            } else {
                SecureField(title, text: value)
            }
        }
        .textContentType(
            creatingAccount ? .newPassword : .password
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .modifier(AuthFieldStyle())
    }

    private func submit() async {
        statusMessage = ""

        let cleanedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard cleanedEmail.contains("@"),
              cleanedEmail.contains(".") else {
            statusMessage = "Enter a valid email address."
            return
        }

        guard password.count >= 8 else {
            statusMessage = "Use a password with at least 8 characters."
            return
        }

        if creatingAccount {
            guard !name.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty else {
                statusMessage = "Enter a display name."
                return
            }

            guard password == confirmation else {
                statusMessage = "Passwords don't match."
                return
            }

            guard isEligible else {
                statusMessage = "Accounts in this prototype are available only to users aged 13 and older."
                return
            }

            let success = await auth.signUp(
                name: name,
                email: cleanedEmail,
                password: password
            )

            if success {
                password = ""
                confirmation = ""
            }
        } else {
            let success = await auth.signIn(
                email: cleanedEmail,
                password: password
            )

            if success {
                password = ""
            }
        }
    }
}

private struct AuthFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(CiviYouTheme.body(15))
            .padding(16)
            .background(
                Color.white,
                in: RoundedRectangle(cornerRadius: 16)
            )
            .textInputAutocapitalization(.never)
    }
}
//
//  AuthView.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//

