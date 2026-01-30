//
//  Attempt.swift
//  Beans
//
//  User attempt tracking model
//

import Foundation
import SwiftData

@Model
final class Attempt {
    var id: UUID
    var challengeId: UUID
    var date: Date
    var didTry: Bool
    var feeling: Feeling?
    var note: String?

    enum Feeling: String, Codable, CaseIterable {
        case awkward = "😬"
        case neutral = "😐"
        case nice = "🙂"
        case amazing = "😄"

        var displayName: String {
            switch self {
            case .awkward: return "Awkward"
            case .neutral: return "Neutral"
            case .nice: return "Nice"
            case .amazing: return "Amazing"
            }
        }
    }

    init(
        id: UUID = UUID(),
        challengeId: UUID,
        date: Date = Date(),
        didTry: Bool = false,
        feeling: Feeling? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.challengeId = challengeId
        self.date = date
        self.didTry = didTry
        self.feeling = feeling
        self.note = note
    }
}
