//
//  LearningJourney.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//


import Foundation
import Combine
import FirebaseAuth

// MARK: - Course Catalog

struct CivicCourse: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
}

enum CivicCourseCatalog {
    static let all: [CivicCourse] = [
        .init(
            id: "who-decides",
            title: "Who Decides?",
            subtitle: "Local, state, and federal government",
            symbol: "building.columns.fill"
        ),
        .init(
            id: "fact-opinion",
            title: "Fact or Opinion?",
            subtitle: "Media literacy and civic claims",
            symbol: "checkmark.seal.fill"
        ),
        .init(
            id: "law",
            title: "How Laws Are Made",
            subtitle: "Bills, voting, and government decisions",
            symbol: "doc.text.fill"
        ),
        .init(
            id: "civic-voice",
            title: "Your Civic Voice",
            subtitle: "Public meetings and community participation",
            symbol: "megaphone.fill"
        ),
        .init(
            id: "public-policy",
            title: "Policy & Public Budgets",
            subtitle: "Public money, evidence, and tradeoffs",
            symbol: "chart.bar.fill"
        ),
        .init(
            id: "elections",
            title: "Elections & Voting",
            subtitle: "Ballots, candidates, and election systems",
            symbol: "checkmark.square.fill"
        ),
        .init(
            id: "constitution",
            title: "The Constitution",
            subtitle: "Rights and the structure of government",
            symbol: "book.closed.fill"
        ),
        .init(
            id: "community",
            title: "Community Problem Solving",
            subtitle: "Turn a local concern into a practical plan",
            symbol: "person.3.fill"
        )
    ]
}

// MARK: - Saved Question Review

struct AnswerReview: Codable, Identifiable {
    var id = UUID()
    let question: String
    let answers: [String]
    let selectedIndex: Int
    let correctIndex: Int
    let explanation: String
}

// MARK: - Completed Round

struct FinishedRound: Codable, Identifiable {
    let id: UUID
    let courseID: String
    let finishedAt: Date
    let level: Int
    let correct: Int
    let answers: [AnswerReview]
}

// MARK: - Local Storage

private struct JourneySnapshot: Codable {
    var levels: [String: Int] = [:]
    var history: [FinishedRound] = []
    var xp = 0
    var lastActivity: Date?
    var streak = 0
}

// MARK: - Learning Journey Store

@MainActor
final class LearningJourney: ObservableObject {

    @Published private(set) var history: [FinishedRound] = []
    @Published private(set) var levels: [String: Int] = [:]
    @Published private(set) var xp = 0
    @Published private(set) var streak = 0
    @Published private(set) var lastActivity: Date?

    private var accountID = ""

    private var storageKey: String {
        "civiyou.learning." + accountID
    }

    init() {
        switchAccount(Auth.auth().currentUser?.uid)
    }

    // MARK: - Account-Specific Progress

    func switchAccount(_ uid: String?) {
        let next = uid ?? "guest"

        guard next != accountID else {
            return
        }

        accountID = next

        let snapshot = UserDefaults.standard
            .data(forKey: storageKey)
            .flatMap {
                try? JSONDecoder().decode(
                    JourneySnapshot.self,
                    from: $0
                )
            } ?? JourneySnapshot()

        levels = snapshot.levels
        history = snapshot.history
        xp = snapshot.xp
        streak = snapshot.streak
        lastActivity = snapshot.lastActivity
    }

    // MARK: - Course Progress

    func level(for courseID: String) -> Int {
        min(5, max(1, levels[courseID] ?? 1))
    }

    func rounds(for courseID: String) -> [FinishedRound] {
        history
            .filter { $0.courseID == courseID }
            .sorted { $0.finishedAt > $1.finishedAt }
    }

    func recentQuestions(for courseID: String) -> [String] {
        Array(
            rounds(for: courseID)
                .prefix(5)
                .flatMap {
                    $0.answers.map(\.question)
                }
                .prefix(15)
        )
    }

    // MARK: - Streak

    var currentStreak: Int {
        guard let lastActivity else {
            return 0
        }

        let calendar = Calendar.current

        if calendar.isDateInToday(lastActivity) ||
            calendar.isDateInYesterday(lastActivity) {
            return streak
        }

        return 0
    }

    // MARK: - Complete Round

    @discardableResult
    func finish(
        courseID: String,
        level: Int,
        answers: [AnswerReview]
    ) -> FinishedRound {

        let correct = answers.filter {
            $0.selectedIndex == $0.correctIndex
        }.count

        let record = FinishedRound(
            id: UUID(),
            courseID: courseID,
            finishedAt: Date(),
            level: level,
            correct: correct,
            answers: answers
        )

        history.insert(record, at: 0)

        // Completion XP plus accuracy bonus.
        xp += 20 + correct * 10

        if !answers.isEmpty && correct == answers.count {
            levels[courseID] = min(5, level + 1)
        } else if correct == 0 && level > 1 {
            levels[courseID] = level - 1
        }

        updateStreak()

        persist()

        return record
    }

    private func updateStreak() {
        let now = Date()
        let calendar = Calendar.current

        if let previous = lastActivity {
            if calendar.isDateInToday(previous) {
                // One streak credit per day.
            } else if calendar.isDateInYesterday(previous) {
                streak += 1
            } else {
                streak = 1
            }
        } else {
            streak = 1
        }

        lastActivity = now
    }

    // MARK: - Save Progress

    private func persist() {
        let snapshot = JourneySnapshot(
            levels: levels,
            history: history,
            xp: xp,
            lastActivity: lastActivity,
            streak: streak
        )

        guard let data = try? JSONEncoder().encode(
            snapshot
        ) else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }
}
