
import SwiftUI

struct RepresentativeFinderView: View {

    @State private var selectedLevel = 0

    private let levels = ["Local", "State", "Federal"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                CiviCard(color: CiviYouTheme.blue) {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 36))

                        Text("Who represents you?")
                            .font(CiviYouTheme.heading(28))

                        Text("Learn which elected officials make decisions about your community, your state, and the country.")
                            .font(CiviYouTheme.body(15))
                    }
                    .foregroundStyle(CiviYouTheme.charcoal)
                }

                Picker("Government level", selection: $selectedLevel) {
                    ForEach(0..<levels.count, id: \.self) { index in
                        Text(levels[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)

                switch selectedLevel {
                case 0:
                    localOffices
                case 1:
                    stateOffices
                default:
                    federalOffices
                }

                CiviCard(color: CiviYouTheme.yellow.opacity(0.5)) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Find your actual representatives")
                            .font(CiviYouTheme.heading(20))

                        Text("Your representatives depend on where you live. CiviYou will support personalized representative lookup in a future update.")
                            .font(CiviYouTheme.body(14))

                        Text("For now, you can learn what each office does and use official government directories to identify your representatives.")
                            .font(CiviYouTheme.body(13))
                    }
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Your Representatives")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var localOffices: some View {
        VStack(spacing: 12) {
            officeCard(
                title: "City Council",
                symbol: "building.2",
                description: "Makes decisions about local laws, city budgets, roads, parks, and services.",
                example: "Want a safer crosswalk or improved neighborhood park? Your city council may be able to help.",
                website: "https://www.usa.gov/local-governments"
            )

            officeCard(
                title: "Mayor",
                symbol: "person.crop.rectangle",
                description: "Helps lead city government. A mayor's specific powers depend on the city.",
                example: "A mayor may help set priorities for transportation, public safety, and city services.",
                website: "https://www.usa.gov/local-governments"
            )

            officeCard(
                title: "School Board",
                symbol: "graduationcap",
                description: "Oversees public school district policies, budgets, and leadership.",
                example: "Concerned about a district-wide school policy? A school board meeting can be a place to learn more.",
                website: "https://www.usa.gov/local-governments"
            )
        }
    }

    private var stateOffices: some View {
        VStack(spacing: 12) {
            officeCard(
                title: "State Representative",
                symbol: "person.text.rectangle",
                description: "Introduces and votes on laws in the state House of Representatives.",
                example: "State representatives can consider legislation affecting education, transportation, and other state issues.",
                website: "https://www.azleg.gov/memberroster/"
            )

            officeCard(
                title: "State Senator",
                symbol: "building.columns",
                description: "Introduces, debates, and votes on legislation in the state Senate.",
                example: "You can contact your senator about proposed state legislation.",
                website: "https://www.azleg.gov/memberroster/"
            )

            officeCard(
                title: "Governor",
                symbol: "checkmark.seal",
                description: "Leads the state executive branch and can sign or veto legislation.",
                example: "A bill approved by the legislature may be sent to the governor for consideration.",
                website: "https://www.usa.gov/state-governor"
            )
        }
    }

    private var federalOffices: some View {
        VStack(spacing: 12) {
            officeCard(
                title: "U.S. Representative",
                symbol: "person.text.rectangle",
                description: "Represents a congressional district in the U.S. House of Representatives.",
                example: "Contact your House representative about federal laws, spending, or government services.",
                website: "https://www.house.gov/representatives/find-your-representative"
            )

            officeCard(
                title: "U.S. Senator",
                symbol: "person.2",
                description: "Represents your entire state in the U.S. Senate. Each state has two senators.",
                example: "Senators vote on federal legislation and consider certain presidential appointments.",
                website: "https://www.senate.gov/senators/"
            )

            officeCard(
                title: "President",
                symbol: "flag",
                description: "Leads the federal executive branch and carries out responsibilities assigned by the Constitution.",
                example: "The president can sign or veto federal legislation and directs executive agencies.",
                website: "https://www.whitehouse.gov"
            )
        }
    }

    private func officeCard(
        title: String,
        symbol: String,
        description: String,
        example: String,
        website: String
    ) -> some View {
        CiviCard {
            VStack(alignment: .leading, spacing: 13) {

                HStack(spacing: 12) {
                    Image(systemName: symbol)
                        .font(.system(size: 24))
                        .frame(width: 35)

                    Text(title)
                        .font(CiviYouTheme.heading(21))
                }

                Text(description)
                    .font(CiviYouTheme.body(14))

                Divider()

                Text("Example")
                    .font(.subheadline.bold())

                Text(example)
                    .font(CiviYouTheme.body(14))

                if let url = URL(string: website) {
                    Link(destination: url) {
                        Label(
                            "Official government resource",
                            systemImage: "arrow.up.right"
                        )
                        .font(.subheadline.bold())
                        .foregroundStyle(CiviYouTheme.charcoal)
                    }
                }
            }
            .foregroundStyle(CiviYouTheme.charcoal)
        }
    }
}
//
//  RepresentativeFinderView.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//

