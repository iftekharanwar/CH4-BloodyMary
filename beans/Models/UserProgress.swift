//
//  UserProgress.swift
//  Beans
//
//  User progress and profile model
//

import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID
    var currentStreak: Int
    var longestStreak: Int
    var totalAttempts: Int
    var displayName: String?
    var isAnonymous: Bool
    var hasCompletedOnboarding: Bool
    var lastAttemptDate: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalAttempts: Int = 0,
        displayName: String? = nil,
        isAnonymous: Bool = true,
        hasCompletedOnboarding: Bool = false,
        lastAttemptDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalAttempts = totalAttempts
        self.displayName = displayName
        self.isAnonymous = isAnonymous
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.lastAttemptDate = lastAttemptDate
        self.createdAt = createdAt
    }
}
