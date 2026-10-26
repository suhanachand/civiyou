//
//  CivicModels.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//


import Foundation

struct AppUser: Codable, Identifiable {
    var id: String
    var nickname: String
    var email: String?
    var interests: [String]
}

struct SourceDocument: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var organization: String
    var url: String
    var verifiedDate: String?
}

struct CivicIssue: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var summary: String
    var category: String
    var jurisdiction: String
    var governmentBody: String
    var happening: String
    var importance: String
    var facts: [String]
    var uncertainty: String
    var questions: [String]
    var sources: [SourceDocument]
    var symbol: String
}

struct Representative: Codable, Identifiable {
    var id: String
    var office: String
    var jurisdiction: String
    var name: String?
    var officialURL: String
}

struct CivicOpportunity: Codable, Identifiable {
    var id: String
    var title: String
    var organization: String
    var summary: String
    var location: String
    var ageEligibility: String
    var dates: String
    var category: String
    var officialURL: String
    var isSample: Bool
}

enum SavedItemType: String, Codable {
    case issue
    case opportunity
    case resource
    case document
}

struct SavedItem: Codable, Identifiable {
    var id: String
    var type: SavedItemType
    var referenceID: String
    var title: String
}

struct ChallengeQuestion: Codable, Identifiable {
    var id: String
    var question: String
    var answers: [String]
    var correctIndex: Int
    var explanation: String
}

struct CivicChallenge: Codable, Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var symbol: String
    var questions: [ChallengeQuestion]
}

struct LearningProgress: Codable {
    var completedChallengeIDs: [String] = []
    var totalCorrectAnswers: Int = 0
}

struct ChatMessage: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var isUser: Bool
    var sources: [SourceDocument] = []
}
