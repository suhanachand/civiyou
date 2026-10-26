//
//  SavedView.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//


import SwiftUI

struct SavedView: View {
    @EnvironmentObject private var store: CiviYouStore

    private var savedIssues: [CivicIssue] {
        store.issues.filter { store.isSaved($0.id) }
    }

    private var savedOpportunities: [CivicOpportunity] {
        store.opportunities.filter { store.isSaved($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 19) {
                CiviSectionHeader(
                    title: "Your saved corner",
                    subtitle: "Keep the things you're curious about."
                )

                if store.savedItems.isEmpty {
                    CiviCard(color: CiviYouTheme.yellow.opacity(0.6)) {
                        VStack(alignment: .leading, spacing: 15) {
                            Image(systemName: "bookmark.circle.fill")
                                .font(.system(size: 52))

                            Text("Nothing saved yet!")
                                .font(CiviYouTheme.heading(23))

                            Text("Explore a civic issue or opportunity and tap its bookmark icon to save it here.")
                                .font(CiviYouTheme.body())
                        }
                    }
                } else {
                    if !savedIssues.isEmpty {
                        CiviSectionHeader(title: "Civic issues")

                        ForEach(savedIssues) { issue in
                            NavigationLink {
                                IssueDetailView(issue: issue)
                            } label: {
                                CiviCard(color: CiviYouTheme.blue.opacity(0.6)) {
                                    HStack {
                                        Image(systemName: issue.symbol)
                                            .font(.title2)

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(issue.title)
                                                .font(CiviYouTheme.heading(19))
                                            Text(issue.category)
                                                .font(.caption)
                                        }

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if !savedOpportunities.isEmpty {
                        CiviSectionHeader(title: "Opportunities")

                        ForEach(savedOpportunities) { opportunity in
                            CiviCard(color: CiviYouTheme.yellow.opacity(0.55)) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(opportunity.title)
                                            .font(CiviYouTheme.heading(19))
                                        Spacer()
                                        BookmarkButton(
                                            isSaved: true
                                        ) {
                                            store.toggleOpportunity(opportunity)
                                        }
                                    }

                                    Text(opportunity.organization)
                                        .font(CiviYouTheme.body(14))

                                    if let url = URL(
                                        string: opportunity.officialURL
                                    ) {
                                        Link("Open official website", destination: url)
                                            .font(.subheadline.bold())
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .toolbar(.hidden, for: .navigationBar)
    }
}
