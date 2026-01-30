//
//  Challenge.swift
//  Beans
//
//  Social courage challenge model
//

import Foundation
import SwiftData

@Model
final class Challenge {
    var id: UUID
    var title: String
    var challengeDescription: String  // Using 'challengeDescription' to avoid conflicts
    var difficulty: Difficulty
    var estimatedTime: String
    var emoji: String
    var illustration: String?  // Asset name for custom illustration
    var category: String
    var isActive: Bool
    var createdAt: Date

    enum Difficulty: String, Codable {
        case easy
        case medium
        case hard

        var displayName: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            }
        }

        var icon: String {
            switch self {
            case .easy: return "leaf"
            case .medium: return "leaf.fill"
            case .hard: return "tree"
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        difficulty: Difficulty,
        estimatedTime: String,
        emoji: String,
        illustration: String? = nil,
        category: String,
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.challengeDescription = description
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.emoji = emoji
        self.illustration = illustration
        self.category = category
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
