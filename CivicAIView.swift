
import SwiftUI
import FirebaseAuth

struct CivicAIView: View {

    @EnvironmentObject private var auth: AuthService

    @AppStorage("civi.agePreference")
    private var agePreference = 0

    @State private var messages: [ChatMessage] = []
    @State private var input = ""
    @State private var isLoading = false
    @State private var showingAgeSetting = false
    @State private var errorMessage: String?
    @State private var failedQuestion: String?
    @State private var loadedAccountID: String?

    private let ai = AIService.shared

    private var accountID: String {
        auth.user?.uid ?? "guest"
    }

    private var chatStorageKey: String {
        "civi.chat." + accountID
    }

    private let suggestions = [
        "What does a city council do?",
        "How does a bill become law in Arizona?",
        "Why do cities have budgets?",
        "How can young people get involved?"
    ]

    // MARK: - Main Screen

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(
                        alignment: .leading,
                        spacing: 16
                    ) {
                        header

                        ForEach(messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }

                        if messages.count <= 1 {
                            suggestionsView
                        }

                        if isLoading {
                            loadingView
                        }

                        if let errorMessage {
                            errorView(errorMessage)
                        }

                        if messages.count > 1 &&
                            !isLoading &&
                            errorMessage == nil {
                            followupButtons
                        }
                    }
                    .padding(18)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { _, _ in
                    scrollToBottom(proxy)
                }
                .onChange(of: isLoading) { _, _ in
                    scrollToBottom(proxy)
                }
            }

            inputBar
        }
        .background(CiviYouTheme.cream)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            loadConversation()
        }
        .onChange(of: accountID) { _, _ in
            loadConversation()
        }
        .sheet(isPresented: $showingAgeSetting) {
            ageSettings
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {

            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundStyle(CiviYouTheme.charcoal)

            Text("Ask CiviAI")
                .font(CiviYouTheme.heading(28))

            CiviPill(
                title: ai.isLiveAvailable
                    ? "CiviAI · Connected account"
                    : "Demo tutor · Curated answers",
                color: ai.isLiveAvailable
                    ? CiviYouTheme.mint
                    : CiviYouTheme.yellow
            )

            Text(
                "Your guide to government, civic issues, and making a difference."
            )
            .font(CiviYouTheme.body(13))
            .foregroundStyle(
                CiviYouTheme.charcoal.opacity(0.7)
            )
            .multilineTextAlignment(.center)

            Button {
                showingAgeSetting = true
            } label: {
                Label(
                    "Adjust reading level",
                    systemImage: "slider.horizontal.3"
                )
                .font(.caption.bold())
                .foregroundStyle(CiviYouTheme.charcoal)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    CiviYouTheme.blue.opacity(0.4),
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 5)

            Text("Conversations are saved on this device.")
                .font(.caption2)
                .foregroundStyle(
                    CiviYouTheme.charcoal.opacity(0.5)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Age Settings

    private var ageSettings: some View {
        NavigationStack {
            Form {

                Section {
                    Text(
                        "CiviAI will adjust the vocabulary, explanations, and examples it uses based on your age."
                    )
                    .font(.subheadline)

                    Picker(
                        "Your age",
                        selection: $agePreference
                    ) {
                        Text("Prefer not to say").tag(0)
                        Text("Under 13").tag(12)

                        ForEach(13...18, id: \.self) { age in
                            Text("\(age) years old").tag(age)
                        }

                        Text("19 or older").tag(19)
                    }
                } header: {
                    Text("Personalize your answers")
                } footer: {
                    Text(
                        "This preference is optional and stored on your device."
                    )
                }

                Section {
                    Text(
                        "CiviAI aims to give short, understandable explanations. You can always ask it to explain more."
                    )
                } header: {
                    Text("How CiviAI responds")
                }
            }
            .navigationTitle("AI Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingAgeSetting = false
                    }
                }
            }
        }
    }

    // MARK: - Suggested Questions

    private var suggestionsView: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Try asking")
                .font(.subheadline.bold())
                .foregroundStyle(CiviYouTheme.charcoal)

            ForEach(suggestions, id: \.self) { question in
                Button {
                    ask(question)
                } label: {
                    HStack(spacing: 12) {

                        Text(question)
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: 8)

                        Image(systemName: "arrow.up.left")
                    }
                    .font(CiviYouTheme.body(14))
                    .foregroundStyle(CiviYouTheme.charcoal)
                    .padding(14)
                    .background(
                        CiviYouTheme.blue.opacity(0.35),
                        in: RoundedRectangle(
                            cornerRadius: 15
                        )
                    )
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
            }
        }
    }

    // MARK: - Message Bubble

    private func messageBubble(
        _ message: ChatMessage
    ) -> some View {

        HStack(alignment: .top) {

            if message.isUser {
                Spacer(minLength: 45)
            }

            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                Text(message.text)
                    .font(CiviYouTheme.body(15))
                    .foregroundStyle(CiviYouTheme.charcoal)
                    .textSelection(.enabled)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                if !message.sources.isEmpty {
                    sourceLinks(message.sources)
                }
            }
            .padding(15)
            .background(
                message.isUser
                    ? CiviYouTheme.yellow
                    : CiviYouTheme.white,
                in: RoundedRectangle(
                    cornerRadius: 20
                )
            )

            if !message.isUser {
                Spacer(minLength: 30)
            }
        }
    }

    // MARK: - Sources

    private func sourceLinks(
        _ sources: [SourceDocument]
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text("Sources")
                .font(.caption.bold())
                .foregroundStyle(CiviYouTheme.charcoal)

            ForEach(sources) { source in
                if let url = URL(string: source.url),
                   url.scheme == "https" {

                    Link(destination: url) {
                        HStack(spacing: 9) {
                            Image(systemName: "link.circle.fill")

                            VStack(
                                alignment: .leading,
                                spacing: 3
                            ) {
                                Text(source.organization)
                                    .font(.caption.bold())

                                Text(source.title)
                                    .font(.caption2)
                            }

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                        .foregroundStyle(CiviYouTheme.charcoal)
                        .padding(10)
                        .background(
                            CiviYouTheme.cream,
                            in: RoundedRectangle(
                                cornerRadius: 12
                            )
                        )
                    }
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        HStack(spacing: 10) {

            ProgressView()
                .tint(CiviYouTheme.charcoal)

            Text("CiviAI is thinking...")
                .font(CiviYouTheme.body(14))
                .foregroundStyle(CiviYouTheme.charcoal)

            Spacer()
        }
        .padding(15)
        .background(
            CiviYouTheme.white,
            in: RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - Error Display

    private func errorView(
        _ message: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Label(
                "Couldn't reach CiviAI",
                systemImage: "wifi.exclamationmark"
            )
            .font(.subheadline.bold())

            Text(message)
                .font(.caption)

            if failedQuestion != nil {
                Button {
                    retry()
                } label: {
                    Label(
                        "Try again",
                        systemImage: "arrow.clockwise"
                    )
                    .font(.caption.bold())
                }
            }
        }
        .foregroundStyle(CiviYouTheme.charcoal)
        .padding(15)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            CiviYouTheme.yellow.opacity(0.3),
            in: RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - Follow-Up Questions

    private var followupButtons: some View {
        HStack(spacing: 8) {
            followup("Explain more simply")
            followup("Give me an example")
        }
    }

    private func followup(
        _ title: String
    ) -> some View {
        Button {
            guard !isLoading,
                  errorMessage == nil,
                  let previousAnswer = messages.last(
                    where: { !$0.isUser }
                  ) else {
                return
            }

            let question =
                title +
                " regarding this explanation: " +
                previousAnswer.text

            ask(question)

        } label: {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(CiviYouTheme.charcoal)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    CiviYouTheme.blue.opacity(0.4),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .disabled(isLoading || errorMessage != nil)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(
            alignment: .bottom,
            spacing: 10
        ) {
            TextField(
                "Ask a civic question...",
                text: $input,
                axis: .vertical
            )
            .lineLimit(1...4)
            .font(CiviYouTheme.body())
            .foregroundStyle(CiviYouTheme.charcoal)
            .padding(12)
            .background(
                CiviYouTheme.white,
                in: RoundedRectangle(cornerRadius: 18)
            )
            .onSubmit(send)
            .disabled(isLoading)

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(
                        CiviYouTheme.charcoal,
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .disabled(
                isLoading ||
                input.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
        }
        .padding(13)
        .background(CiviYouTheme.cream)
    }

    // MARK: - Send

    private func send() {
        let question = input.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !question.isEmpty,
              !isLoading else {
            return
        }

        input = ""
        ask(question)
    }

    // MARK: - Ask Gemini

    private func ask(_ question: String) {

        guard !isLoading else {
            return
        }

        let trimmed = question.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty else {
            return
        }

        errorMessage = nil
        failedQuestion = nil

        // Remember the previous conversation.
        let history = Array(messages.dropFirst())

        let requestAccountID = accountID

        messages.append(
            ChatMessage(
                text: trimmed,
                isUser: true
            )
        )

        saveConversation()

        isLoading = true

        Task {
            do {
                let response = try await ai.ask(
                    trimmed,
                    history: history,
                    age: agePreference == 0
                        ? nil
                        : agePreference
                )

                // Don't put an answer in another
                // account's conversation.
                guard accountID == requestAccountID else {
                    isLoading = false
                    return
                }

                messages.append(
                    ChatMessage(
                        text: response.text,
                        isUser: false,
                        sources: response.sources
                    )
                )

                saveConversation()

                errorMessage = nil
                failedQuestion = nil

            } catch {
                guard accountID == requestAccountID else {
                    isLoading = false
                    return
                }

                failedQuestion = trimmed

                print("========== CIVIAI ERROR ==========")
                print(String(reflecting: error))
                print("==================================")

                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    // MARK: - Retry

    private func retry() {
        guard !isLoading,
              let question = failedQuestion else {
            return
        }

        if let last = messages.last,
           last.isUser,
           last.text == question {
            messages.removeLast()
        }

        failedQuestion = nil
        errorMessage = nil

        ask(question)
    }

    // MARK: - Save Conversations

    private func saveConversation() {
        guard let data = try? JSONEncoder().encode(
            Array(messages.suffix(100))
        ) else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: chatStorageKey
        )
    }

    // MARK: - Load Conversations

    private func loadConversation() {

        guard loadedAccountID != accountID else {
            return
        }

        loadedAccountID = accountID

        errorMessage = nil
        failedQuestion = nil
        isLoading = false

        if let data = UserDefaults.standard.data(
            forKey: chatStorageKey
        ),
        let saved = try? JSONDecoder().decode(
            [ChatMessage].self,
            from: data
        ),
        !saved.isEmpty {
            messages = saved
        } else {
            messages = [
                ChatMessage(
                    text: "Hi! I'm CiviAI. Ask me anything about government, civic issues, or your community.",
                    isUser: false
                )
            ]
        }
    }

    // MARK: - Auto Scroll

    private func scrollToBottom(
        _ proxy: ScrollViewProxy
    ) {
        guard let last = messages.last else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(
                last.id,
                anchor: .bottom
            )
        }
    }
}
