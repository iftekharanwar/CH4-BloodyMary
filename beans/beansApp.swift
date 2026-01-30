//
//  beansApp.swift
//  beans
//
//  Created by Iftekhar Anwar on 29/01/26.
//

import SwiftUI
import SwiftData

@main
struct beansApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [Challenge.self, Attempt.self, UserProgress.self])
    }
}
