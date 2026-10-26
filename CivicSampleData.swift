//
//  CivicSampleData.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//


import Foundation

enum CivicSampleData {
    static let issues: [CivicIssue] = [
        CivicIssue(
            id: "water",
            title: "Arizona's Water Future",
            summary: "How do cities plan for water in a dry climate?",
            category: "Environment",
            jurisdiction: "Arizona",
            governmentBody: "Arizona Department of Water Resources",
            happening: "Arizona communities plan for long-term water supplies while managing drought, growth, and groundwater use.",
            importance: "Water availability affects homes, farms, businesses, and future development. Different government agencies regulate different parts of the water system.",
            facts: [
                "Arizona uses water from multiple sources, including groundwater, the Colorado River, and in-state rivers.",
                "The state regulates groundwater in designated Active Management Areas.",
                "Local governments also make decisions about water infrastructure and development."
            ],
            uncertainty: "Future supplies depend on weather, conservation, population changes, and decisions involving multiple states and governments.",
            questions: [
                "Who determines how much groundwater may be used?",
                "How can cities compare water-saving policies?",
                "What evidence should guide new development?"
            ],
            sources: [
                SourceDocument(
                    id: "adwr",
                    title: "Arizona Department of Water Resources",
                    organization: "State of Arizona",
                    url: "https://www.azwater.gov",
                    verifiedDate: nil
                )
            ],
            symbol: "drop.fill"
        ),
        CivicIssue(
            id: "heat",
            title: "Living With Extreme Heat",
            summary: "How can cities make public spaces safer during hot weather?",
            category: "Public Health",
            jurisdiction: "Phoenix, Arizona",
            governmentBody: "City of Phoenix",
            happening: "Phoenix faces recurring periods of extreme summer heat. Government agencies coordinate public information, infrastructure, and heat-response planning.",
            importance: "Heat affects how residents use transportation, parks, sidewalks, and other public spaces. Choices about shade and infrastructure can change the experience of a neighborhood.",
            facts: [
                "Phoenix has an Office of Heat Response and Mitigation.",
                "Heat planning can involve public facilities, shade, and emergency coordination.",
                "Municipal budgets influence which projects receive funding."
            ],
            uncertainty: "The effectiveness and cost of specific heat-reduction projects differ by location and implementation.",
            questions: [
                "Where would additional shade provide the greatest benefit?",
                "How should cities evaluate a heat-reduction project?"
            ],
            sources: [
                SourceDocument(
                    id: "phoenix",
                    title: "City of Phoenix",
                    organization: "City of Phoenix",
                    url: "https://www.phoenix.gov",
                    verifiedDate: nil
                )
            ],
            symbol: "sun.max.fill"
        ),
        CivicIssue(
            id: "parks",
            title: "Who Decides Where Parks Go?",
            summary: "Explore how community needs influence city planning.",
            category: "Community",
            jurisdiction: "Phoenix, Arizona",
            governmentBody: "Phoenix City Council and city departments",
            happening: "Local governments make decisions about park planning, maintenance, and public spending.",
            importance: "Parks provide places for recreation and community activities. Residents may have different views about where investment is most needed.",
            facts: [
                "City departments develop and administer public programs.",
                "Elected city councils make important budget and policy decisions.",
                "Public meetings offer opportunities to learn about proposed decisions."
            ],
            uncertainty: "A particular project may depend on funding, land availability, and decisions that have not yet been made.",
            questions: [
                "How can residents find park planning proposals?",
                "What makes a fair process for choosing locations?"
            ],
            sources: [
                SourceDocument(
                    id: "parks-source",
                    title: "Phoenix Parks and Recreation",
                    organization: "City of Phoenix",
                    url: "https://www.phoenix.gov",
                    verifiedDate: nil
                )
            ],
            symbol: "tree.fill"
        )
    ]

    static let opportunities: [CivicOpportunity] = [
        CivicOpportunity(
            id: "public-meetings",
            title: "Explore a City Council Meeting",
            organization: "City of Phoenix",
            summary: "Learn how agendas, public meetings, and local decisions work.",
            location: "Phoenix, AZ",
            ageEligibility: "Public educational activity",
            dates: "Check the official meeting calendar",
            category: "Civic Learning",
            officialURL: "https://www.phoenix.gov",
            isSample: true
        ),
        CivicOpportunity(
            id: "library",
            title: "Discover Library Programs",
            organization: "Phoenix Public Library",
            summary: "Explore community learning activities and programs.",
            location: "Phoenix, AZ",
            ageEligibility: "Varies by program",
            dates: "Check current listings",
            category: "Community",
            officialURL: "https://www.phoenixpubliclibrary.org",
            isSample: true
        )
    ]

    static let challenges: [CivicChallenge] = [
        CivicChallenge(
            id: "who-decides",
            title: "Who Decides?",
            subtitle: "Match public decisions to government.",
            symbol: "building.columns.fill",
            questions: [
                ChallengeQuestion(
                    id: "wd1",
                    question: "Who usually approves a city's annual budget?",
                    answers: ["City council", "The U.S. Supreme Court", "A school principal"],
                    correctIndex: 0,
                    explanation: "An elected city council generally votes on the municipal budget."
                ),
                ChallengeQuestion(
                    id: "wd2",
                    question: "Who makes laws for the State of Arizona?",
                    answers: ["The federal courts", "The Arizona Legislature", "The Phoenix library"],
                    correctIndex: 1,
                    explanation: "The Arizona Legislature passes state bills, which may become laws through the constitutional process."
                )
            ]
        ),
        CivicChallenge(
            id: "fact-opinion",
            title: "Fact or Opinion?",
            subtitle: "Learn how to assess civic claims.",
            symbol: "checkmark.seal.fill",
            questions: [
                ChallengeQuestion(
                    id: "fo1",
                    question: "\"Phoenix is the capital of Arizona.\" This is:",
                    answers: ["An opinion", "A verifiable fact", "A prediction"],
                    correctIndex: 1,
                    explanation: "The state capital is a verifiable fact."
                ),
                ChallengeQuestion(
                    id: "fo2",
                    question: "\"Every city should build more parks.\" This is:",
                    answers: ["A policy opinion", "A historical date", "A measurement"],
                    correctIndex: 0,
                    explanation: "The word 'should' expresses a recommendation that people can debate."
                )
            ]
        ),
        CivicChallenge(
            id: "law",
            title: "How a Bill Becomes Law",
            subtitle: "Understand Arizona's lawmaking process.",
            symbol: "doc.text.fill",
            questions: [
                ChallengeQuestion(
                    id: "law1",
                    question: "What must generally happen before an Arizona bill can be sent to the governor?",
                    answers: ["A public social media vote", "Approval by both legislative chambers", "Approval by every city"],
                    correctIndex: 1,
                    explanation: "Both legislative chambers generally must approve the same version of a bill."
                ),
                ChallengeQuestion(
                    id: "law2",
                    question: "Can a governor veto a bill?",
                    answers: ["Yes", "Never", "Only after a public referendum"],
                    correctIndex: 0,
                    explanation: "Arizona's governor can veto legislation. The legislature may override a veto if constitutional requirements are met."
                )
            ]
        )
    ]
}
