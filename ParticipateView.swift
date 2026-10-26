
import SwiftUI
import Combine
import FirebaseAuth

// MARK: - Civic Actions

struct CivicAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
    let symbol: String
    let steps: [String]
    let reflectionPrompt: String
}

enum CivicActionCatalog {
    static let all: [CivicAction] = [
        .init(
            id: "community-issue",
            title: "Solve a Community Problem",
            subtitle: "Research a local concern and develop a proposal.",
            category: "Community",
            symbol: "lightbulb.fill",
            steps: [
                "Choose a specific local problem.",
                "Gather evidence from at least two sources.",
                "Identify who can make a decision about it.",
                "Develop a realistic proposed solution."
            ],
            reflectionPrompt: "What would make your proposal realistic and effective?"
        ),
        .init(
            id: "public-meeting",
            title: "Attend a Public Meeting",
            subtitle: "Observe a public decision and document what happened.",
            category: "Government",
            symbol: "building.columns.fill",
            steps: [
                "Find an upcoming public meeting or recording.",
                "Read the official agenda.",
                "Attend or watch the meeting.",
                "Record a decision and the reasoning behind it."
            ],
            reflectionPrompt: "What question would you ask the officials?"
        ),
        .init(
            id: "write-official",
            title: "Contact a Public Official",
            subtitle: "Write a message proposing a specific action.",
            category: "Government",
            symbol: "envelope.fill",
            steps: [
                "Choose an issue you understand.",
                "Identify the responsible public office.",
                "Prepare a specific and respectful request.",
                "Review and optionally send your message."
            ],
            reflectionPrompt: "What response or action would you hope to receive?"
        ),
        .init(
            id: "volunteer",
            title: "Complete a Volunteer Project",
            subtitle: "Support an established community organization.",
            category: "Volunteer",
            symbol: "hands.sparkles",
            steps: [
                "Choose a cause.",
                "Find an organization and check eligibility.",
                "Sign up for an appropriate supervised opportunity.",
                "Record what you contributed and learned."
            ],
            reflectionPrompt: "What need did your volunteer work address?"
        ),
        .init(
            id: "fact-check",
            title: "Investigate a Public Claim",
            subtitle: "Research a claim and prepare an evidence-based explanation.",
            category: "Research",
            symbol: "checkmark.shield.fill",
            steps: [
                "Choose a factual civic claim.",
                "Find its original source.",
                "Check supporting and contradictory evidence.",
                "Write a fair conclusion and cite your sources."
            ],
            reflectionPrompt: "What could you verify, and what remains uncertain?"
        ),
        .init(
            id: "youth-voice",
            title: "Explore Youth Leadership",
            subtitle: "Find a program where young people advise or serve.",
            category: "Community",
            symbol: "person.3.fill",
            steps: [
                "Identify a youth-serving public or community program.",
                "Research eligibility and responsibilities.",
                "Investigate what participants can actually influence.",
                "Develop an application or inquiry."
            ],
            reflectionPrompt: "What meaningful responsibility should youth representatives hold?"
        ),
        .init(
            id: "community-survey",
            title: "Listen to Your Community",
            subtitle: "Learn how other people understand an issue.",
            category: "Research",
            symbol: "bubble.left.and.bubble.right.fill",
            steps: [
                "Choose an issue affecting your community.",
                "Prepare three neutral questions.",
                "Collect voluntary, non-identifying responses.",
                "Summarize different perspectives fairly."
            ],
            reflectionPrompt: "What did the responses change about your understanding?"
        ),
        .init(
            id: "budget",
            title: "Review a Public Budget",
            subtitle: "Examine local spending and identify a question for officials.",
            category: "Government",
            symbol: "chart.bar.fill",
            steps: [
                "Find an official local budget.",
                "Identify a spending category.",
                "Compare the spending with stated priorities.",
                "Prepare a question or recommendation."
            ],
            reflectionPrompt: "What would you ask decision-makers to justify?"
        )
    ]
}

// MARK: - Saved Progress

struct CivicActionProgress: Codable {
    var completedStepIndexes: [Int] = []
    var reflection: String = ""
    var completedAt: Date?
}

@MainActor
final class ParticipationTracker: ObservableObject {

    @Published private(set)
    var progress: [String: CivicActionProgress] = [:]

    private var accountID = ""

    private var storageKey: String {
        "civiyou.participation." + accountID
    }

    init() {
        switchAccount(Auth.auth().currentUser?.uid)
    }

    func switchAccount(_ uid: String?) {
        let newID = uid ?? "guest"
        guard newID != accountID else { return }

        accountID = newID

        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(
                [String: CivicActionProgress].self,
                from: data
           ) {
            progress = decoded
        } else {
            progress = [:]
        }
    }

    func record(for action: CivicAction) -> CivicActionProgress {
        progress[action.id] ?? CivicActionProgress()
    }

    func update(
        _ record: CivicActionProgress,
        for action: CivicAction
    ) {
        progress[action.id] = record
        save()
    }

    func toggleStep(_ index: Int, for action: CivicAction) {
        var item = record(for: action)
        guard item.completedAt == nil else { return }

        if item.completedStepIndexes.contains(index) {
            item.completedStepIndexes.removeAll { $0 == index }
        } else {
            item.completedStepIndexes.append(index)
        }

        update(item, for: action)
    }

    func finish(_ action: CivicAction) {
        var item = record(for: action)

        guard item.completedAt == nil,
              Set(item.completedStepIndexes).count ==
                action.steps.count else { return }

        item.completedAt = Date()
        update(item, for: action)
    }

    var completedCount: Int {
        CivicActionCatalog.all.filter {
            record(for: $0).completedAt != nil
        }.count
    }

    var inProgressCount: Int {
        CivicActionCatalog.all.filter {
            let item = record(for: $0)
            return item.completedAt == nil &&
                !item.completedStepIndexes.isEmpty
        }.count
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress)
        else { return }

        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

// MARK: - Main Act Tab

struct ParticipateView: View {

    @EnvironmentObject private var auth: AuthService

    @StateObject private var tracker = ParticipationTracker()

    @State private var category = "All"

    private let categories = [
        "All", "Community", "Government", "Volunteer", "Research"
    ]

    private var filteredActions: [CivicAction] {
        CivicActionCatalog.all.filter {
            category == "All" || $0.category == category
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                dashboard
                opportunitiesSection
                actionsSection
                activityRecord
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tracker.switchAccount(auth.user?.uid)
        }
        .onChange(of: auth.user?.uid) { _, newID in
            tracker.switchAccount(newID)
        }
    }

    private var header: some View {
        CiviCard(color: CiviYouTheme.pink) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 38))

                Text("Take Action")
                    .font(CiviYouTheme.heading(31))

                Text("Turn your interests into projects, service, and meaningful community participation.")
                    .font(CiviYouTheme.body(15))

                CiviPill(
                    title: "Your community action hub",
                    color: .white
                )
            }
            .foregroundStyle(CiviYouTheme.charcoal)
        }
    }

    private var dashboard: some View {
        CiviCard(color: CiviYouTheme.mint.opacity(0.65)) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your impact journal")
                    .font(CiviYouTheme.heading(22))

                HStack {
                    statistic(
                        tracker.completedCount,
                        label: "Completed"
                    )

                    Spacer()

                    statistic(
                        tracker.inProgressCount,
                        label: "In progress"
                    )

                    Spacer()

                    statistic(
                        CivicActionCatalog.all.count,
                        label: "Projects"
                    )
                }
            }
        }
    }

    private func statistic(
        _ value: Int,
        label: String
    ) -> some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(CiviYouTheme.heading(27))
            Text(label)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }

    private var opportunitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            CiviSectionHeader(
                title: "Find an opportunity",
                subtitle: "Volunteer, serve, or take part in a youth program near you."
            )

            NavigationLink {
                ArizonaOpportunitiesView()
            } label: {
                CiviCard(color: CiviYouTheme.yellow) {
                    HStack(spacing: 13) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 30))

                        VStack(alignment: .leading, spacing: 7) {
                            Text("Arizona Opportunity Finder")
                                .font(CiviYouTheme.heading(21))

                            Text("Find programs by age, ZIP code, and interests.")
                                .font(CiviYouTheme.body(13))
                        }

                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(CiviYouTheme.charcoal)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            CiviSectionHeader(
                title: "Community action projects",
                subtitle: "Choose a project and build a record of what you accomplish."
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { option in
                        Button {
                            category = option
                        } label: {
                            Text(option)
                                .font(.caption.bold())
                                .foregroundStyle(CiviYouTheme.charcoal)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    category == option
                                        ? CiviYouTheme.yellow
                                        : CiviYouTheme.white,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            ForEach(filteredActions) { action in
                NavigationLink {
                    CivicActionDetailView(
                        action: action,
                        tracker: tracker
                    )
                } label: {
                    CiviCard(color: CiviYouTheme.white) {
                        HStack(spacing: 13) {
                            Image(systemName: action.symbol)
                                .font(.title2)
                                .frame(width: 35)

                            VStack(alignment: .leading, spacing: 7) {
                                Text(action.title)
                                    .font(CiviYouTheme.heading(20))

                                Text(action.subtitle)
                                    .font(CiviYouTheme.body(13))

                                let record = tracker.record(for: action)

                                Text(
                                    record.completedAt != nil
                                        ? "Completed"
                                        : "\(record.completedStepIndexes.count) of \(action.steps.count) steps"
                                )
                                .font(.caption.bold())
                            }

                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(CiviYouTheme.charcoal)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var activityRecord: some View {
        VStack(alignment: .leading, spacing: 12) {
            CiviSectionHeader(
                title: "Your activity record",
                subtitle: "Revisit completed projects and saved work."
            )

            let completed = CivicActionCatalog.all.filter {
                tracker.record(for: $0).completedAt != nil
            }

            if completed.isEmpty {
                CiviCard(color: CiviYouTheme.blue.opacity(0.35)) {
                    Text("Your completed projects will appear here.")
                        .font(CiviYouTheme.body(14))
                }
            }

            ForEach(completed) { action in
                NavigationLink {
                    CivicActionDetailView(
                        action: action,
                        tracker: tracker
                    )
                } label: {
                    Label(
                        action.title,
                        systemImage: "checkmark.seal.fill"
                    )
                    .padding(14)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        CiviYouTheme.white,
                        in: RoundedRectangle(cornerRadius: 13)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Action Project Workspace

struct CivicActionDetailView: View {

    let action: CivicAction

    @ObservedObject var tracker: ParticipationTracker

    @State private var projectTitle = ""
    @State private var communityNeed = ""
    @State private var proposedAction = ""
    @State private var intendedContact = ""
    @State private var evidenceNotes = ""
    @State private var reflectionText = ""
    @State private var outcomeNotes = ""

    private var record: CivicActionProgress {
        tracker.record(for: action)
    }

    private var completed: Bool {
        record.completedAt != nil
    }

    private var allStepsComplete: Bool {
        Set(record.completedStepIndexes).count ==
            action.steps.count
    }

    private var detailKey: String {
        "civiyou.project." +
        (Auth.auth().currentUser?.uid ?? "guest") +
        "." + action.id
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                CiviCard(color: CiviYouTheme.yellow) {
                    VStack(alignment: .leading, spacing: 11) {
                        Image(systemName: action.symbol)
                            .font(.largeTitle)

                        Text(action.title)
                            .font(CiviYouTheme.heading(27))

                        Text(action.subtitle)
                            .font(CiviYouTheme.body(15))
                    }
                }

                planningSection
                checklistSection
                draftSection
                resultsSection

                if completed {
                    CiviCard(color: CiviYouTheme.mint) {
                        Label(
                            "Project completed",
                            systemImage: "checkmark.seal.fill"
                        )
                        .font(.headline)
                    }
                } else {
                    CiviPrimaryButton(
                        title: allStepsComplete
                            ? "Finish project"
                            : "Complete all project steps",
                        symbol: "checkmark.circle.fill"
                    ) {
                        saveWork()
                        tracker.finish(action)
                    }
                    .disabled(!allStepsComplete)
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Action Project")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            restoreWork()
        }
        .onDisappear {
            saveWork()
        }
    }

    private var planningSection: some View {
        CiviCard {
            VStack(alignment: .leading, spacing: 13) {
                Text("1. Build your action plan")
                    .font(CiviYouTheme.heading(22))

                projectField(
                    "Project title",
                    placeholder: "What are you working on?",
                    text: $projectTitle
                )

                projectField(
                    "Community need",
                    placeholder: "What problem are you addressing?",
                    text: $communityNeed
                )

                projectField(
                    "Your proposed action",
                    placeholder: "What would you like to change or accomplish?",
                    text: $proposedAction
                )

                projectField(
                    "Who can help?",
                    placeholder: "Organization, public office, or community partner",
                    text: $intendedContact
                )

                projectField(
                    "Evidence and research",
                    placeholder: "Notes, useful sources, and findings",
                    text: $evidenceNotes
                )

                Button("Save action plan") {
                    saveWork()
                }
                .font(.subheadline.bold())
            }
        }
    }

    private var checklistSection: some View {
        CiviCard(color: CiviYouTheme.blue.opacity(0.4)) {
            VStack(alignment: .leading, spacing: 13) {
                Text("2. Complete your project steps")
                    .font(CiviYouTheme.heading(22))

                ForEach(
                    Array(action.steps.enumerated()),
                    id: \.offset
                ) { index, step in
                    Button {
                        tracker.toggleStep(index, for: action)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(
                                systemName:
                                    record.completedStepIndexes.contains(index)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .font(.title3)

                            Text(step)
                                .font(CiviYouTheme.body(15))
                                .multilineTextAlignment(.leading)

                            Spacer()
                        }
                        .foregroundStyle(CiviYouTheme.charcoal)
                    }
                    .buttonStyle(.plain)
                    .disabled(completed)
                }

                ProgressView(
                    value: Double(
                        Set(record.completedStepIndexes).count
                    ),
                    total: Double(action.steps.count)
                )
                .tint(CiviYouTheme.charcoal)
            }
        }
    }

    private var draftSection: some View {
        CiviCard(color: CiviYouTheme.pink.opacity(0.5)) {
            VStack(alignment: .leading, spacing: 12) {
                Text("3. Prepare your outreach")
                    .font(CiviYouTheme.heading(22))

                Text("Use your research to prepare a message for a relevant organization or public office.")
                    .font(CiviYouTheme.body(14))

                Text(outreachDraft)
                    .font(CiviYouTheme.body(14))
                    .textSelection(.enabled)

                Button {
                    #if os(iOS)
                    UIPasteboard.general.string = outreachDraft
                    #elseif os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(
                        outreachDraft,
                        forType: .string
                    )
                    #endif
                } label: {
                    Label("Copy draft", systemImage: "doc.on.doc")
                        .font(.subheadline.bold())
                }

                Text("Review the message before sending it. CiviYou does not send messages automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var resultsSection: some View {
        CiviCard(color: CiviYouTheme.mint.opacity(0.4)) {
            VStack(alignment: .leading, spacing: 12) {
                Text("4. Record your results")
                    .font(CiviYouTheme.heading(22))

                projectField(
                    "What happened?",
                    placeholder: "Record your activity, responses, or progress",
                    text: $outcomeNotes
                )

                projectField(
                    "What did you learn?",
                    placeholder: action.reflectionPrompt,
                    text: $reflectionText
                )

                Button("Save your record") {
                    saveWork()
                }
                .font(.subheadline.bold())

                Text("You can return to this workspace to review your project.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func projectField(
        _ title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())

            TextField(
                placeholder,
                text: text,
                axis: .vertical
            )
            .lineLimit(2...5)
            .padding(12)
            .background(
                CiviYouTheme.white,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .disabled(completed)
        }
    }

    private var outreachDraft: String {
        """
        Hello,

        I'm working on a community project concerning \(communityNeed.isEmpty ? "[community issue]" : communityNeed).

        I would like to propose \(proposedAction.isEmpty ? "[proposed action]" : proposedAction).

        I've researched the issue and would appreciate learning how your office or organization could help address it.

        Thank you for your time.
        """
    }

    private struct ProjectNotes: Codable {
        var title = ""
        var need = ""
        var proposal = ""
        var contact = ""
        var evidence = ""
        var reflection = ""
        var outcome = ""
    }

    private func saveWork() {
        let notes = ProjectNotes(
            title: projectTitle,
            need: communityNeed,
            proposal: proposedAction,
            contact: intendedContact,
            evidence: evidenceNotes,
            reflection: reflectionText,
            outcome: outcomeNotes
        )

        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: detailKey)
        }

        var progress = tracker.record(for: action)
        progress.reflection = reflectionText
        tracker.update(progress, for: action)
    }

    private func restoreWork() {
        if let data = UserDefaults.standard.data(forKey: detailKey),
           let notes = try? JSONDecoder().decode(
                ProjectNotes.self,
                from: data
           ) {
            projectTitle = notes.title
            communityNeed = notes.need
            proposedAction = notes.proposal
            intendedContact = notes.contact
            evidenceNotes = notes.evidence
            reflectionText = notes.reflection
            outcomeNotes = notes.outcome
        } else {
            reflectionText = record.reflection
        }
    }
}
