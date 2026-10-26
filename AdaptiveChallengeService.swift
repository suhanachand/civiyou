//
//  AdaptiveChallengeService.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//

import Foundation
import FirebaseAuth
import FirebaseAILogic

// MARK: - Adaptive Learning Models

struct AdaptiveLearningState: Codable {
    var levels: [String: Int] = [:]
    var roundsCompleted: Int = 0
    var recentQuestions: [String] = []

    func level(for topic: String) -> Int {
        min(5, max(1, levels[topic] ?? 1))
    }
}

struct GeneratedQuestion: Codable {
    let question: String
    let answers: [String]
    let correctIndex: Int
    let explanation: String
}

struct GeneratedRound: Codable {
    let questions: [GeneratedQuestion]
}

// MARK: - Adaptive Challenge Generator

final class AdaptiveChallengeService {

    static let shared = AdaptiveChallengeService()

    private let model = FirebaseAI
        .firebaseAI(backend: .googleAI())
        .generativeModel(
            modelName: "gemini-3.8-flash"
        )

    private init() {}

    func generate(
        topic: String,
        level: Int,
        age: Int?,
        recentQuestions: [String]
    ) async throws -> GeneratedRound {

        // Use built-in practice if the student
        // is not signed into Firebase.
        guard Auth.auth().currentUser != nil else {
            return demoRound()
        }

        let safeLevel = min(5, max(1, level))

        let levelDescription: String

        switch safeLevel {
        case 1:
            levelDescription = "Basic civic vocabulary and recognition."
        case 2:
            levelDescription = "Simple real-world civic situations."
        case 3:
            levelDescription = "Applying knowledge to community decisions."
        case 4:
            levelDescription = "Comparing options and understanding policy tradeoffs."
        default:
            levelDescription = "Complex but age-appropriate civic reasoning."
        }

        let ageInstruction: String

        if let age {
            ageInstruction =
                "The learner is \(age) years old. Adjust language and examples accordingly."
        } else {
            ageInstruction =
                "Use accessible secondary-school language."
        }

        let previous = recentQuestions
            .suffix(6)
            .joined(separator: "\n")

        let prompt = """
        You are an expert civic education quiz writer.

        Create EXACTLY 3 multiple-choice questions.

        Topic: \(topic)
        Difficulty level: \(safeLevel) out of 5.
        Difficulty guidance: \(levelDescription)

        \(ageInstruction)

        REQUIREMENTS:
        - Teach accurate, politically nonpartisan civic knowledge.
        - Focus on US government and civic participation.
        - Use realistic situations, not trivia.
        - Each question has exactly 4 answer choices.
        - Only one answer may be correct.
        - Use correctIndex values 0, 1, 2, or 3.
        - Vary the position of correct answers.
        - Keep questions under 35 words.
        - Keep each answer choice under 18 words.
        - Explain answers in 1-2 short sentences.
        - Avoid partisan persuasion, fabricated laws,
          changing officeholder names, and current events.
        - Ensure questions can be answered using
          established civic knowledge.
        - Make questions different from previous rounds.

        Previously asked questions:
        \(previous)

        Return ONLY valid JSON in this exact structure:
        {
          "questions": [
            {
              "question": "Question text",
              "answers": [
                "Option A",
                "Option B",
                "Option C",
                "Option D"
              ],
              "correctIndex": 0,
              "explanation": "Short factual explanation"
            }
          ]
        }

        Do not include Markdown or code fences.
        """

        let response = try await model.generateContent(prompt)

        guard let text = response.text else {
            throw ChallengeGenerationError.emptyResponse
        }

        let cleaned = text
            .replacingOccurrences(
                of: "```json",
                with: ""
            )
            .replacingOccurrences(
                of: "```",
                with: ""
            )
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard let start = cleaned.firstIndex(of: "{"),
              let end = cleaned.lastIndex(of: "}") else {
            throw ChallengeGenerationError.invalidResponse
        }

        let json = String(cleaned[start...end])

        guard let data = json.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(
                  GeneratedRound.self,
                  from: data
              ) else {
            throw ChallengeGenerationError.invalidResponse
        }

        guard decoded.questions.count == 3 else {
            throw ChallengeGenerationError.invalidResponse
        }

        for question in decoded.questions {
            guard question.answers.count == 4,
                  (0...3).contains(question.correctIndex),
                  !question.question.isEmpty,
                  !question.explanation.isEmpty,
                  question.answers.allSatisfy({
                      !$0.trimmingCharacters(
                          in: .whitespacesAndNewlines
                      ).isEmpty
                  }) else {
                throw ChallengeGenerationError.invalidResponse
            }
        }

        return decoded
    }

    // MARK: - Guest Practice

    private func demoRound() -> GeneratedRound {
        GeneratedRound(questions: [
            GeneratedQuestion(
                question: "Which level of government usually manages city parks?",
                answers: [
                    "Federal government",
                    "City government",
                    "United Nations",
                    "U.S. Senate"
                ],
                correctIndex: 1,
                explanation: "Municipal governments usually manage city parks through local departments."
            ),
            GeneratedQuestion(
                question: "What is the main purpose of a public budget?",
                answers: [
                    "To choose election winners",
                    "To replace all taxes",
                    "To plan revenue and spending",
                    "To appoint judges"
                ],
                correctIndex: 2,
                explanation: "A public budget outlines government revenue and planned expenditures."
            ),
            GeneratedQuestion(
                question: "How can a student share concerns about a city policy?",
                answers: [
                    "Attend a council meeting",
                    "Veto a law personally",
                    "Appoint a senator",
                    "Issue an executive order"
                ],
                correctIndex: 0,
                explanation: "Many city councils allow residents, including students, to share comments under their public participation rules."
            )
        ])
    }
}

enum ChallengeGenerationError: LocalizedError {
    case emptyResponse
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "CiviAI didn't return questions. Please try again."
        case .invalidResponse:
            return "CiviAI couldn't format this challenge. Please generate another round."
        }
    }
}

