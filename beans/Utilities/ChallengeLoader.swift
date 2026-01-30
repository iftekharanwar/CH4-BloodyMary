//
//  ChallengeLoader.swift
//  Beans
//
//  Utility to load initial challenges from JSON
//

import Foundation
import SwiftData

@MainActor
class ChallengeLoader {
    struct ChallengeData: Codable {
        let id: String
        let title: String
        let description: String
        let difficulty: String
        let estimatedTime: String
        let emoji: String
        let illustration: String?
        let category: String
    }

    static func loadInitialChallenges(context: ModelContext) {
        // Check if challenges already exist
        let descriptor = FetchDescriptor<Challenge>()
        let existingChallenges = (try? context.fetch(descriptor)) ?? []

        guard existingChallenges.isEmpty else {
            print("Challenges already loaded")
            return
        }

        // Load from JSON
        guard let url = Bundle.main.url(forResource: "Challenges", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let challengesData = try? JSONDecoder().decode([ChallengeData].self, from: data) else {
            print("Failed to load challenges from JSON")
            return
        }

        // Convert to Challenge models
        for challengeData in challengesData {
            let difficulty: Challenge.Difficulty
            switch challengeData.difficulty.lowercased() {
            case "easy":
                difficulty = .easy
            case "medium":
                difficulty = .medium
            case "hard":
                difficulty = .hard
            default:
                difficulty = .easy
            }

            let challenge = Challenge(
                id: UUID(uuidString: challengeData.id) ?? UUID(),
                title: challengeData.title,
                description: challengeData.description,
                difficulty: difficulty,
                estimatedTime: challengeData.estimatedTime,
                emoji: challengeData.emoji,
                illustration: challengeData.illustration,
                category: challengeData.category
            )

            context.insert(challenge)
        }

        do {
            try context.save()
            print("Successfully loaded \(challengesData.count) challenges")
        } catch {
            print("Failed to save challenges: \(error)")
        }
    }
}
