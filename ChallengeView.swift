//
//  ChallengeView.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//


import SwiftUI
import FirebaseAuth

struct ChallengeListView: View {

    @EnvironmentObject private var store: CiviYouStore
    @EnvironmentObject private var auth: AuthService

    @StateObject private var journey = LearningJourney()

    @AppStorage("civi.agePreference")
    private var agePreference = 0

    @State private var selectedCourse: CivicCourse?
    @State private var round: GeneratedRound?
    @State private var activeLevel = 1
    @State private var questionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var answers: [AnswerReview] = []
    @State private var isLoading = false
    @State private var finished = false
    @State private var errorMessage: String?
    @State private var showingHistory = false

    private var accountID: String {
        auth.user?.uid ?? "guest"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                dashboard

                if let course = selectedCourse {
                    if let round {
                        if finished {
                            resultsView(course, round: round)
                        } else {
                            questionView(course, round: round)
                        }
                    } else {
                        courseOverview(course)
                    }
                } else {
                    courseCatalog
                }

                if isLoading {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Preparing your lesson...")
                    }
                    .padding(15)
                }

                if let errorMessage {
                    CiviCard(color: CiviYouTheme.pink) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Couldn't load your lesson")
                                .font(.headline)

                            Text(errorMessage)
                                .font(.subheadline)

                            Button("Try again") {
                                generateRound()
                            }
                            .disabled(isLoading)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Civic Learning")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            journey.switchAccount(auth.user?.uid)
        }
        .onChange(of: accountID) { _, _ in
            round = nil
            selectedCourse = nil
            finished = false
            errorMessage = nil
            journey.switchAccount(auth.user?.uid)
        }
        .sheet(isPresented: $showingHistory) {
            NavigationStack {
                reviewHistory
            }
        }
    }

    // MARK: - Dashboard

    private var dashboard: some View {
        CiviCard(color: CiviYouTheme.blue) {
            VStack(alignment: .leading, spacing: 15) {

                Text("Your Civic Journey")
                    .font(CiviYouTheme.heading(29))

                Text("Learn something new. Build your knowledge.")
                    .font(CiviYouTheme.body(14))

                HStack(spacing: 10) {
                    stat(
                        "flame.fill",
                        "\(journey.currentStreak)",
                        "Day streak"
                    )

                    stat(
                        "bolt.fill",
                        "\(journey.xp)",
                        "Total XP"
                    )

                    stat(
                        "checkmark.seal.fill",
                        "\(journey.history.count)",
                        "Rounds"
                    )
                }

                Button {
                    showingHistory = true
                } label: {
                    Label(
                        "Review my learning history",
                        systemImage: "clock.arrow.circlepath"
                    )
                    .font(.subheadline.bold())
                    .foregroundStyle(CiviYouTheme.charcoal)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(
                        CiviYouTheme.white,
                        in: RoundedRectangle(cornerRadius: 13)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func stat(
        _ symbol: String,
        _ value: String,
        _ label: String
    ) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title3)

            Text(value)
                .font(CiviYouTheme.heading(23))

            Text(label)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(CiviYouTheme.charcoal)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            CiviYouTheme.white.opacity(0.7),
            in: RoundedRectangle(cornerRadius: 13)
        )
    }

    // MARK: - Course Catalog

    private var courseCatalog: some View {
        VStack(alignment: .leading, spacing: 13) {

            Text("Choose your course")
                .font(CiviYouTheme.heading(25))

            Text("Every subject has five levels. Your progress is saved separately for each course.")
                .font(CiviYouTheme.body(14))

            ForEach(CivicCourseCatalog.all) { course in
                Button {
                    selectedCourse = course
                    round = nil
                    finished = false
                    errorMessage = nil
                } label: {
                    CiviCard(color: CiviYouTheme.white) {
                        HStack(spacing: 13) {

                            Image(systemName: course.symbol)
                                .font(.system(size: 26))
                                .frame(width: 40)
                                .foregroundStyle(CiviYouTheme.charcoal)

                            VStack(alignment: .leading, spacing: 7) {
                                Text(course.title)
                                    .font(CiviYouTheme.heading(20))

                                Text(course.subtitle)
                                    .font(CiviYouTheme.body(12))

                                Text(
                                    "Level \(journey.level(for: course.id))/5 · \(journey.rounds(for: course.id).count) rounds"
                                )
                                .font(.caption.bold())

                                ProgressView(
                                    value: Double(
                                        journey.level(for: course.id) - 1
                                    ),
                                    total: 4
                                )
                                .tint(CiviYouTheme.charcoal)
                            }
                            .foregroundStyle(CiviYouTheme.charcoal)

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .foregroundStyle(CiviYouTheme.charcoal)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Course Overview

    private func courseOverview(
        _ course: CivicCourse
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            Button {
                selectedCourse = nil
            } label: {
                Label("All courses", systemImage: "arrow.left")
            }
            .buttonStyle(.plain)

            CiviCard(color: CiviYouTheme.yellow) {
                VStack(alignment: .leading, spacing: 12) {

                    Image(systemName: course.symbol)
                        .font(.largeTitle)

                    Text(course.title)
                        .font(CiviYouTheme.heading(27))

                    Text(course.subtitle)
                        .font(CiviYouTheme.body(15))

                    Text("Current level: \(journey.level(for: course.id)) of 5")
                        .font(.subheadline.bold())

                    Text(
                        "Complete each round to earn XP. Perfect scores unlock the next difficulty level."
                    )
                    .font(CiviYouTheme.body(13))

                    CiviPrimaryButton(
                        title: journey.rounds(for: course.id).isEmpty
                            ? "Start course"
                            : "Continue learning",
                        symbol: "arrow.right"
                    ) {
                        generateRound()
                    }
                }
            }

            let previous = journey.rounds(for: course.id)

            if !previous.isEmpty {
                Text("Previous lessons")
                    .font(CiviYouTheme.heading(21))

                ForEach(previous.prefix(3)) { record in
                    NavigationLink {
                        RoundReviewView(record: record)
                    } label: {
                        historyCard(record)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Generate Lesson

    private func generateRound() {
        guard let course = selectedCourse,
              !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        round = nil
        finished = false
        questionIndex = 0
        selectedAnswer = nil
        answers = []

        activeLevel = journey.level(for: course.id)

        // Preserve the original quizzes as
        // introductory lessons for their courses.
        if journey.rounds(for: course.id).isEmpty,
           let original = store.challenges.first(
                where: { $0.id == course.id }
           ),
           !original.questions.isEmpty {

            round = GeneratedRound(
                questions: original.questions.map {
                    GeneratedQuestion(
                        question: $0.question,
                        answers: $0.answers,
                        correctIndex: $0.correctIndex,
                        explanation: $0.explanation
                    )
                }
            )

            isLoading = false
            return
        }

        let requestedAccount = accountID
        let requestedTopic = course.id

        Task {
            do {
                let generated = try await
                    AdaptiveChallengeService.shared.generate(
                        topic: course.title,
                        level: activeLevel,
                        age: agePreference == 0
                            ? nil
                            : agePreference,
                        recentQuestions: journey.recentQuestions(
                            for: course.id
                        )
                    )

                guard accountID == requestedAccount,
                      selectedCourse?.id == requestedTopic else {
                    isLoading = false
                    return
                }

                round = generated

            } catch {
                guard accountID == requestedAccount else {
                    isLoading = false
                    return
                }

                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    // MARK: - Question Screen

    private func questionView(
        _ course: CivicCourse,
        round: GeneratedRound
    ) -> some View {

        let question = round.questions[questionIndex]

        return VStack(alignment: .leading, spacing: 15) {

            Button {
                roundExit()
            } label: {
                Label("Back to course", systemImage: "arrow.left")
            }

            HStack {
                Text(course.title)
                    .font(.subheadline.bold())

                Spacer()

                Text(
                    "\(questionIndex + 1) of \(round.questions.count)"
                )
                .font(.caption.bold())
            }

            ProgressView(
                value: Double(questionIndex + 1),
                total: Double(round.questions.count)
            )

            CiviCard(color: CiviYouTheme.blue) {
                VStack(alignment: .leading, spacing: 12) {

                    Text("LEVEL \(activeLevel)")
                        .font(.caption.bold())

                    Text(question.question)
                        .font(CiviYouTheme.heading(23))
                }
            }

            ForEach(
                question.answers.indices,
                id: \.self
            ) { index in

                Button {
                    chooseAnswer(index)
                } label: {
                    HStack {
                        Text(question.answers[index])
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if selectedAnswer != nil &&
                            index == question.correctIndex {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .font(CiviYouTheme.body(15))
                    .foregroundStyle(CiviYouTheme.charcoal)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        answerBackground(
                            index,
                            correct: question.correctIndex
                        ),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                }
                .buttonStyle(.plain)
                .disabled(selectedAnswer != nil)
            }

            if selectedAnswer != nil {
                CiviCard(
                    color: CiviYouTheme.mint.opacity(0.5)
                ) {
                    VStack(alignment: .leading, spacing: 12) {

                        Text(
                            selectedAnswer == question.correctIndex
                                ? "Correct!"
                                : "Here's why"
                        )
                        .font(CiviYouTheme.heading(21))

                        Text(question.explanation)
                            .font(CiviYouTheme.body(15))

                        CiviPrimaryButton(
                            title: questionIndex + 1 ==
                                round.questions.count
                                ? "Finish lesson"
                                : "Next question",
                            symbol: "arrow.right"
                        ) {
                            nextQuestion(round)
                        }
                    }
                }
            }
        }
    }

    private func answerBackground(
        _ index: Int,
        correct: Int
    ) -> Color {
        guard let selectedAnswer else {
            return CiviYouTheme.white
        }

        if index == correct {
            return CiviYouTheme.mint
        }

        if index == selectedAnswer {
            return CiviYouTheme.peach
        }

        return CiviYouTheme.white
    }

    private func chooseAnswer(_ index: Int) {
        guard selectedAnswer == nil,
              let round,
              questionIndex < round.questions.count else {
            return
        }

        selectedAnswer = index

        let question = round.questions[questionIndex]

        answers.append(
            AnswerReview(
                question: question.question,
                answers: question.answers,
                selectedIndex: index,
                correctIndex: question.correctIndex,
                explanation: question.explanation
            )
        )
    }

    // MARK: - Completion

    private func nextQuestion(
        _ round: GeneratedRound
    ) {
        if questionIndex + 1 < round.questions.count {
            questionIndex += 1
            selectedAnswer = nil
            return
        }

        guard let course = selectedCourse else {
            return
        }

        let completed = journey.finish(
            courseID: course.id,
            level: activeLevel,
            answers: answers
        )

        store.finishChallenge(
            "adaptive-\(completed.id.uuidString)",
            correct: completed.correct
        )

        finished = true
    }

    // MARK: - Results

    private func resultsView(
        _ course: CivicCourse,
        round: GeneratedRound
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            CiviCard(color: CiviYouTheme.mint) {
                VStack(alignment: .leading, spacing: 14) {

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))

                    Text("Lesson complete!")
                        .font(CiviYouTheme.heading(27))

                    let correct = answers.filter {
                        $0.selectedIndex == $0.correctIndex
                    }.count

                    Text(
                        "\(correct) of \(round.questions.count) correct"
                    )
                    .font(CiviYouTheme.heading(22))

                    Text("+\(20 + correct * 10) XP earned")
                        .font(.headline)

                    Text(
                        "Current course level: \(journey.level(for: course.id))"
                    )
                    .font(CiviYouTheme.body(14))
                }
            }

            if let latest = journey.rounds(
                for: course.id
            ).first {
                NavigationLink {
                    RoundReviewView(record: latest)
                } label: {
                    Label(
                        "Review your answers",
                        systemImage: "book"
                    )
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(
                        CiviYouTheme.white,
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                }
                .buttonStyle(.plain)
            }

            CiviPrimaryButton(
                title: "Next lesson",
                symbol: "sparkles"
            ) {
                generateRound()
            }

            Button("Back to courses") {
                roundExit()
                selectedCourse = nil
            }
            .frame(maxWidth: .infinity)
            .padding(12)
        }
    }

    private func roundExit() {
        round = nil
        finished = false
        selectedAnswer = nil
        questionIndex = 0
        answers = []
        errorMessage = nil
    }

    // MARK: - Review History

    private var reviewHistory: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text("Your Learning History")
                    .font(CiviYouTheme.heading(27))

                Text(
                    "Revisit your questions, answers, and explanations."
                )
                .font(CiviYouTheme.body(14))

                if journey.history.isEmpty {
                    ContentUnavailableView(
                        "No completed lessons yet",
                        systemImage: "book.closed",
                        description: Text(
                            "Finish a course lesson to save it here."
                        )
                    )
                }

                ForEach(journey.history) { record in
                    NavigationLink {
                        RoundReviewView(record: record)
                    } label: {
                        historyCard(record)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Review History")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    showingHistory = false
                }
            }
        }
    }

    private func historyCard(
        _ record: FinishedRound
    ) -> some View {
        CiviCard(color: CiviYouTheme.white) {
            HStack {
                VStack(alignment: .leading, spacing: 7) {

                    Text(
                        CivicCourseCatalog.all.first {
                            $0.id == record.courseID
                        }?.title ?? "Civic Lesson"
                    )
                    .font(CiviYouTheme.heading(19))

                    Text(
                        record.finishedAt.formatted(
                            date: .abbreviated,
                            time: .omitted
                        )
                    )
                    .font(.caption)

                    Text(
                        "\(record.correct)/\(record.answers.count) correct · Level \(record.level)"
                    )
                    .font(.caption.bold())
                }
                .foregroundStyle(CiviYouTheme.charcoal)

                Spacer()

                Image(systemName: "chevron.right")
            }
        }
    }
}

// MARK: - Detailed Review Screen

struct RoundReviewView: View {

    let record: FinishedRound

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Lesson Review")
                    .font(CiviYouTheme.heading(27))

                Text(
                    record.finishedAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                ForEach(Array(record.answers.enumerated()),
                        id: \.element.id) { index, answer in

                    CiviCard(color: CiviYouTheme.white) {
                        VStack(alignment: .leading, spacing: 12) {

                            Text("Question \(index + 1)")
                                .font(.caption.bold())

                            Text(answer.question)
                                .font(CiviYouTheme.heading(20))

                            if answer.answers.indices.contains(
                                answer.selectedIndex
                            ) {
                                Text(
                                    "Your answer: " +
                                    answer.answers[answer.selectedIndex]
                                )
                                .font(CiviYouTheme.body(14))
                            }

                            if answer.answers.indices.contains(
                                answer.correctIndex
                            ) {
                                Text(
                                    "Correct answer: " +
                                    answer.answers[answer.correctIndex]
                                )
                                .font(CiviYouTheme.body(14))
                                    .bold()
                            }

                            Divider()

                            Text(answer.explanation)
                                .font(CiviYouTheme.body(14))
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Review Answers")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ChallengeDetailView: View {
    let challenge: CivicChallenge

    var body: some View {
        ChallengeListView()
    }
}
