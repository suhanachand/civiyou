
import SwiftUI

// MARK: - Explore

struct ExploreView: View {

    
    @AppStorage("civi.explore.section")
    private var selectedSection = 0


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                CiviSectionHeader(
                    title: "Explore",
                    subtitle: "Learn about civic life, understand government, and join the conversation."
                )

                Picker(
                    "Explore section",
                    selection: $selectedSection
                ) {
                    Text("Learn").tag(0)
                    Text("Government").tag(1)
                    Text("Voices").tag(2)
                }
                .pickerStyle(.segmented)

                switch selectedSection {
                case 0:
                    learnSection

                case 1:
                    governmentSection

                default:
                    YouthVoicesView()
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Learning

    private var learnSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            CiviCard(color: CiviYouTheme.yellow) {
                VStack(alignment: .leading, spacing: 12) {

                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 38))

                    Text("Civic Learning Academy")
                        .font(CiviYouTheme.heading(27))

                    Text(
                        "Find your course, answer adaptive questions, build XP, and maintain your learning streak."
                    )
                    .font(CiviYouTheme.body(15))

                    NavigationLink {
                        ChallengeListView()
                    } label: {
                        Label(
                            "Choose a course",
                            systemImage: "arrow.right"
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
                        .background(
                            CiviYouTheme.white,
                            in: RoundedRectangle(
                                cornerRadius: 13
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            CiviSectionHeader(
                title: "Learning guides",
                subtitle: "Build the knowledge to understand civic issues and decisions."
            )

            guideCard(
                title: "Understanding Elections",
                summary: "Learn how voting, candidates, and election systems work.",
                symbol: "checkmark.square.fill",
                color: CiviYouTheme.blue,
                text: """
                Elections allow eligible voters to choose representatives and other public officials.

                In the United States, election responsibilities are shared by state and local governments under federal and state law.

                Rules for registration, identification, voting methods, and deadlines differ by state.

                When researching an election, use official election information and compare credible sources.
                """
            )

            guideCard(
                title: "Your Constitutional Rights",
                summary: "Explore the Constitution and the Bill of Rights.",
                symbol: "book.closed.fill",
                color: CiviYouTheme.mint,
                text: """
                The United States Constitution establishes the federal government's structure and protects important rights.

                The First Amendment protects speech, religion, the press, assembly, and petition, subject to legal limits.

                Other amendments establish additional protections and rules for government.

                Understanding constitutional rights requires considering both the text and how courts interpret it.
                """
            )

            guideCard(
                title: "Media Literacy",
                summary: "Practice separating evidence, claims, and opinion.",
                symbol: "checkmark.shield.fill",
                color: CiviYouTheme.pink,
                text: """
                When you encounter a claim, find its original source and check the publication date.

                Look for evidence that can independently support or challenge the claim.

                An opinion expresses a viewpoint. A factual claim can be evaluated using evidence.

                Reliable civic research makes room for uncertainty rather than treating every headline as settled fact.
                """
            )

            guideCard(
                title: "Public Policy",
                summary: "Understand how communities evaluate solutions.",
                symbol: "chart.bar.fill",
                color: CiviYouTheme.yellow,
                text: """
                Public policy is a course of action adopted or considered by government to address a problem.

                Policy decisions involve goals, available resources, legal authority, evidence, and tradeoffs.

                A useful policy analysis asks who benefits, who bears costs, what alternatives exist, and how success will be measured.
                """
            )

            guideCard(
                title: "Civic Participation",
                summary: "Understand the many ways people contribute.",
                symbol: "person.3.fill",
                color: CiviYouTheme.blue,
                text: """
                Civic participation includes community service, public meetings, research, discussion, and communicating with government officials.

                Young people can contribute to many community decisions even before they are eligible to vote.

                Visit Act when you are ready to turn civic knowledge into a concrete community project.
                """
            )
        }
    }

    // MARK: - Government

    private var governmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            CiviCard(color: CiviYouTheme.blue) {
                VStack(alignment: .leading, spacing: 12) {

                    Image(
                        systemName: "building.columns.fill"
                    )
                    .font(.system(size: 38))

                    Text("Understand Government")
                        .font(CiviYouTheme.heading(27))

                    Text(
                        "Explore the institutions and people responsible for decisions in your community."
                    )
                    .font(CiviYouTheme.body(15))
                }
            }

            NavigationLink {
                RepresentativeFinderView()
            } label: {
                CiviCard(color: CiviYouTheme.yellow) {
                    HStack(spacing: 13) {

                        Image(
                            systemName: "person.crop.rectangle.stack.fill"
                        )
                        .font(.system(size: 27))

                        VStack(
                            alignment: .leading,
                            spacing: 6
                        ) {
                            Text("Your Representatives")
                                .font(CiviYouTheme.heading(21))

                            Text(
                                "Understand local, state, and federal offices."
                            )
                            .font(CiviYouTheme.body(13))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(
                        CiviYouTheme.charcoal
                    )
                }
            }
            .buttonStyle(.plain)

            CiviSectionHeader(
                title: "How government works"
            )

            guideCard(
                title: "Local Government",
                summary: "City councils, mayors, counties, and schools.",
                symbol: "building.2.fill",
                color: CiviYouTheme.mint,
                text: """
                City governments often manage local roads, parks, libraries, and municipal services.

                City councils generally adopt local laws and approve spending. A mayor's powers depend on the city charter and form of government.

                Counties have separate responsibilities. Public school districts are overseen by school governing boards under state law.
                """
            )

            guideCard(
                title: "Arizona State Government",
                summary: "The governor, legislature, and courts.",
                symbol: "sun.max.fill",
                color: CiviYouTheme.pink,
                text: """
                Arizona's state government has legislative, executive, and judicial branches.

                The Legislature includes a House of Representatives and Senate. Legislators consider state laws and budgets.

                The governor leads the executive branch. State courts interpret and apply laws.

                Arizona cities, counties, and school districts also carry out responsibilities under state law.
                """
            )

            guideCard(
                title: "Federal Government",
                summary: "Congress, the president, and the courts.",
                symbol: "building.columns.fill",
                color: CiviYouTheme.blue,
                text: """
                Congress is the federal legislative branch and includes the House of Representatives and the Senate.

                The president leads the executive branch, which carries out federal law.

                Federal courts decide cases arising under federal law and the Constitution.

                Checks and balances distribute power among these branches.
                """
            )

            guideCard(
                title: "How a Bill Becomes Law",
                summary: "From proposal to debate, voting, and approval.",
                symbol: "doc.text.fill",
                color: CiviYouTheme.yellow,
                text: """
                A bill is a proposal for a law.

                In Congress, a bill can be introduced, reviewed by committees, debated, and voted upon.

                Both chambers generally must approve identical text before the bill goes to the president.

                The president may sign or veto a bill. Congress can override a veto with the constitutionally required votes.
                """
            )

            guideCard(
                title: "Public Meetings & Budgets",
                summary: "See how officials discuss public spending.",
                symbol: "calendar",
                color: CiviYouTheme.mint,
                text: """
                Government budgets describe expected revenue and planned expenditures.

                Public meetings can help residents understand how decisions are made.

                Agendas, meeting minutes, and budget documents provide useful starting points for research.

                Meeting attendance and public-comment rules vary by public body.
                """
            )
        }
    }

    // MARK: - Guide Navigation

    private func guideCard(
        title: String,
        summary: String,
        symbol: String,
        color: Color,
        text: String
    ) -> some View {
        NavigationLink {
            CivicGuideView(
                title: title,
                bodyText: text
            )
        } label: {
            CiviCard(
                color: color.opacity(0.6)
            ) {
                HStack(spacing: 13) {

                    Image(systemName: symbol)
                        .font(.system(size: 25))
                        .frame(width: 36)

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {
                        Text(title)
                            .font(CiviYouTheme.heading(20))

                        Text(summary)
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

// MARK: - Civic Guide Detail

struct CivicGuideView: View {

    let title: String
    let bodyText: String

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 18
            ) {
                Text(title)
                    .font(CiviYouTheme.heading(29))

                Text(bodyText)
                    .font(CiviYouTheme.body(16))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                CiviCard(
                    color: CiviYouTheme.yellow.opacity(0.45)
                ) {
                    Text(
                        "Ready to use what you've learned? Open Act to explore opportunities and community projects."
                    )
                    .font(CiviYouTheme.body(14))
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Civic Guide")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Existing Issue Detail Compatibility

struct IssueDetailView: View {

    @EnvironmentObject private var store: CiviYouStore

    let issue: CivicIssue

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 15
            ) {
                CiviCard(color: CiviYouTheme.blue) {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: issue.symbol)
                            .font(.largeTitle)

                        Text(issue.title)
                            .font(CiviYouTheme.heading(28))

                        Text(issue.summary)
                            .font(CiviYouTheme.body(15))

                        BookmarkButton(
                            isSaved: store.isSaved(issue.id)
                        ) {
                            store.toggleIssue(issue)
                        }
                    }
                }

                detailCard(
                    "What's happening?",
                    issue.happening
                )

                detailCard(
                    "Why it matters",
                    issue.importance
                )

                detailCard(
                    "Who makes decisions?",
                    issue.governmentBody
                )

                detailCard(
                    "What is uncertain?",
                    issue.uncertainty
                )

                CiviCard {
                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Text("Key facts")
                            .font(CiviYouTheme.heading(20))

                        ForEach(
                            issue.facts,
                            id: \.self
                        ) { fact in
                            Text("• \(fact)")
                                .font(CiviYouTheme.body(14))
                        }
                    }
                }

                CiviCard {
                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Text("Sources")
                            .font(CiviYouTheme.heading(20))

                        ForEach(issue.sources) { source in
                            if let url = URL(
                                string: source.url
                            ),
                            url.scheme == "https" {
                                Link(
                                    source.title,
                                    destination: url
                                )
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Civic Issue")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func detailCard(
        _ title: String,
        _ content: String
    ) -> some View {
        CiviCard {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                Text(title)
                    .font(CiviYouTheme.heading(20))

                Text(content)
                    .font(CiviYouTheme.body(15))
            }
        }
    }
}
