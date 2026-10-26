//
//  YouthVoicesView.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//


import SwiftUI
import Combine
import FirebaseAuth

// MARK: - Models

struct YouthVoicePost: Codable, Identifiable {
    var id = UUID()
    var authorID: String
    var authorName: String
    var title: String
    var content: String
    var category: String
    var createdAt = Date()
    var comments: [YouthVoiceComment] = []
}

struct YouthVoiceComment: Codable, Identifiable {
    var id = UUID()
    var authorID: String
    var authorName: String
    var content: String
    var createdAt = Date()
}

// MARK: - Local Discussion Store

@MainActor
final class YouthVoicesStore: ObservableObject {

    @Published private(set) var posts: [YouthVoicePost] = []

    private var accountID = ""

    private var storageKey: String {
        "civiyou.voices.local." + accountID
    }

    func switchAccount(_ uid: String?) {
        let next = uid ?? "guest"
        guard next != accountID else { return }

        accountID = next

        if let data = UserDefaults.standard.data(
            forKey: storageKey
        ),
        let decoded = try? JSONDecoder().decode(
            [YouthVoicePost].self,
            from: data
        ) {
            posts = decoded
        } else {
            posts = []
        }
    }

    func addPost(
        title: String,
        content: String,
        category: String,
        authorID: String,
        authorName: String
    ) {
        let title = String(
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).prefix(100)
        )

        let content = String(
            content.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).prefix(2500)
        )

        guard !title.isEmpty && !content.isEmpty else {
            return
        }

        posts.insert(
            YouthVoicePost(
                authorID: authorID,
                authorName: authorName,
                title: title,
                content: content,
                category: category
            ),
            at: 0
        )

        save()
    }

    func addComment(
        to postID: UUID,
        content: String,
        authorID: String,
        authorName: String
    ) {
        guard let index = posts.firstIndex(
            where: { $0.id == postID }
        ) else {
            return
        }

        let content = String(
            content.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).prefix(1000)
        )

        guard !content.isEmpty else { return }

        posts[index].comments.append(
            YouthVoiceComment(
                authorID: authorID,
                authorName: authorName,
                content: content
            )
        )

        save()
    }

    func deletePost(
        _ id: UUID,
        authorID: String
    ) {
        posts.removeAll {
            $0.id == id && $0.authorID == authorID
        }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(posts)
        else { return }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }
}

// MARK: - Voices Main View

struct YouthVoicesView: View {

    @EnvironmentObject private var auth: AuthService
    @EnvironmentObject private var store: CiviYouStore

    @StateObject private var voices = YouthVoicesStore()

    @State private var category = "All"
    @State private var search = ""
    @State private var showingComposer = false

    private let categories = [
        "All",
        "Community",
        "Government",
        "Education",
        "Environment",
        "Ideas",
        "Questions"
    ]

    private var authorID: String {
        auth.user?.uid ?? "guest"
    }

    private var authorName: String {
        let name = auth.isSignedIn
            ? auth.nickname
            : store.nickname

        let trimmed = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty
            ? "CiviYou Explorer"
            : trimmed
    }

    private var filteredPosts: [YouthVoicePost] {
        voices.posts.filter { post in
            let categoryMatches =
                category == "All" ||
                post.category == category

            let searchMatches =
                search.isEmpty ||
                post.title.localizedCaseInsensitiveContains(search) ||
                post.content.localizedCaseInsensitiveContains(search)

            return categoryMatches && searchMatches
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 17) {

                    CiviCard(color: CiviYouTheme.pink) {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(
                                systemName: "bubble.left.and.bubble.right.fill"
                            )
                            .font(.largeTitle)

                            Text("Youth Voices")
                                .font(CiviYouTheme.heading(29))

                            Text(
                                "Share ideas, ask questions, and make room for different perspectives."
                            )
                            .font(CiviYouTheme.body(15))

                            Button {
                                showingComposer = true
                            } label: {
                                Label(
                                    "Start a discussion",
                                    systemImage: "square.and.pencil"
                                )
                                .font(.subheadline.bold())
                                .foregroundStyle(CiviYouTheme.charcoal)
                                .padding(13)
                                .background(
                                    CiviYouTheme.yellow,
                                    in: RoundedRectangle(
                                        cornerRadius: 13
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    CiviCard(
                        color: CiviYouTheme.blue.opacity(0.3)
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                "Private preview",
                                systemImage: "lock.shield"
                            )
                            .font(.subheadline.bold())

                            Text(
                                "Posts and comments are saved only on this device. They are not visible to other students yet."
                            )
                            .font(CiviYouTheme.body(13))
                        }
                    }

                    TextField(
                        "Search discussions",
                        text: $search
                    )
                    .textFieldStyle(.roundedBorder)

                    ScrollView(
                        .horizontal,
                        showsIndicators: false
                    ) {
                        HStack(spacing: 8) {
                            ForEach(
                                categories,
                                id: \.self
                            ) { item in

                                Button {
                                    category = item
                                } label: {
                                    Text(item)
                                        .font(.caption.bold())
                                        .padding(
                                            .horizontal,
                                            13
                                        )
                                        .padding(
                                            .vertical,
                                            10
                                        )
                                        .foregroundStyle(
                                            CiviYouTheme.charcoal
                                        )
                                        .background(
                                            category == item
                                                ? CiviYouTheme.yellow
                                                : CiviYouTheme.white,
                                            in: Capsule()
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HStack {
                        Text("Discussions")
                            .font(CiviYouTheme.heading(23))

                        Spacer()

                        Text("\(filteredPosts.count)")
                            .font(.subheadline.bold())
                    }

                    if filteredPosts.isEmpty {
                        CiviCard(
                            color: CiviYouTheme.mint.opacity(0.4)
                        ) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("A conversation starts with a question.")
                                    .font(CiviYouTheme.heading(20))

                                Text(
                                    "There are no posts matching this view yet. Start a discussion about something happening in your community."
                                )
                                .font(CiviYouTheme.body(14))
                            }
                        }
                    }

                    ForEach(filteredPosts) { post in
                        NavigationLink {
                            YouthVoicePostDetailView(
                                postID: post.id,
                                voices: voices,
                                authorID: authorID,
                                authorName: authorName
                            )
                        } label: {
                            postCard(post)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .background(CiviYouTheme.cream)
        .onAppear {
            voices.switchAccount(auth.user?.uid)
        }
        .onChange(of: auth.user?.uid) { _, next in
            voices.switchAccount(next)
        }
        .sheet(isPresented: $showingComposer) {
            YouthVoiceComposerView(
                authorID: authorID,
                authorName: authorName,
                voices: voices
            )
        }
    }

    private func postCard(
        _ post: YouthVoicePost
    ) -> some View {
        CiviCard(color: CiviYouTheme.white) {
            VStack(alignment: .leading, spacing: 12) {
                CiviPill(
                    title: post.category,
                    color: CiviYouTheme.blue
                )

                Text(post.title)
                    .font(CiviYouTheme.heading(21))

                Text(post.content)
                    .font(CiviYouTheme.body(14))
                    .lineLimit(4)

                Divider()

                HStack {
                    Label(
                        post.authorName,
                        systemImage: "person.crop.circle"
                    )

                    Spacer()

                    Label(
                        "\(post.comments.count)",
                        systemImage: "bubble.left"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .foregroundStyle(CiviYouTheme.charcoal)
        }
    }
}

// MARK: - Compose Post

struct YouthVoiceComposerView: View {

    @Environment(\.dismiss)
    private var dismiss

    let authorID: String
    let authorName: String

    @ObservedObject var voices: YouthVoicesStore

    @State private var title = ""
    @State private var content = ""
    @State private var category = "Community"

    private let categories = [
        "Community",
        "Government",
        "Education",
        "Environment",
        "Ideas",
        "Questions"
    ]

    private var canPublish: Bool {
        !title.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty &&
        !content.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your discussion") {

                    TextField(
                        "Give your post a title",
                        text: $title
                    )
                    .onChange(of: title) { _, value in
                        title = String(value.prefix(100))
                    }

                    Picker("Category", selection: $category) {
                        ForEach(
                            categories,
                            id: \.self
                        ) {
                            Text($0).tag($0)
                        }
                    }

                    TextEditor(text: $content)
                        .frame(minHeight: 180)
                        .onChange(of: content) { _, value in
                            content = String(value.prefix(2500))
                        }
                }

                Section {
                    Text(
                        "Share ideas respectfully. Avoid posting private contact information, exact locations, or identifying information about other students."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Discussion")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save Post") {
                        voices.addPost(
                            title: title,
                            content: content,
                            category: category,
                            authorID: authorID,
                            authorName: authorName
                        )
                        dismiss()
                    }
                    .disabled(!canPublish)
                }
            }
        }
    }
}

// MARK: - Discussion and Comments

struct YouthVoicePostDetailView: View {

    let postID: UUID

    @ObservedObject var voices: YouthVoicesStore

    let authorID: String
    let authorName: String

    @Environment(\.dismiss)
    private var dismiss

    @State private var commentText = ""

    private var post: YouthVoicePost? {
        voices.posts.first { $0.id == postID }
    }

    var body: some View {
        ScrollView {
            if let post {
                VStack(alignment: .leading, spacing: 17) {

                    CiviCard(color: CiviYouTheme.pink) {
                        VStack(alignment: .leading, spacing: 12) {
                            CiviPill(
                                title: post.category,
                                color: .white
                            )

                            Text(post.title)
                                .font(CiviYouTheme.heading(27))

                            Text(post.content)
                                .font(CiviYouTheme.body(16))
                                .textSelection(.enabled)

                            Text(
                                "Posted by \(post.authorName)"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }

                    if post.authorID == authorID {
                        Button(
                            "Delete discussion",
                            role: .destructive
                        ) {
                            voices.deletePost(
                                postID,
                                authorID: authorID
                            )
                            dismiss()
                        }
                        .font(.caption.bold())
                    }

                    Text(
                        "Comments (\(post.comments.count))"
                    )
                    .font(CiviYouTheme.heading(23))

                    ForEach(post.comments) { comment in
                        CiviCard(color: CiviYouTheme.white) {
                            VStack(alignment: .leading, spacing: 9) {
                                Text(comment.authorName)
                                    .font(.subheadline.bold())

                                Text(comment.content)
                                    .font(CiviYouTheme.body(14))

                                Text(
                                    comment.createdAt.formatted(
                                        date: .abbreviated,
                                        time: .shortened
                                    )
                                )
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }

                    CiviCard(
                        color: CiviYouTheme.blue.opacity(0.35)
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add your perspective")
                                .font(CiviYouTheme.heading(20))

                            TextField(
                                "Write a thoughtful comment...",
                                text: $commentText,
                                axis: .vertical
                            )
                            .lineLimit(3...6)
                            .onChange(
                                of: commentText
                            ) { _, value in
                                commentText = String(
                                    value.prefix(1000)
                                )
                            }

                            CiviPrimaryButton(
                                title: "Add Comment",
                                symbol: "paperplane.fill"
                            ) {
                                voices.addComment(
                                    to: postID,
                                    content: commentText,
                                    authorID: authorID,
                                    authorName: authorName
                                )
                                commentText = ""
                            }
                            .disabled(
                                commentText.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty
                            )
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Discussion")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
