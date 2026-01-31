//
//  MainTabView.swift
//  Beans
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.969, green: 0.949, blue: 0.933, alpha: 1.0)

        let unselected = UIColor(red: 0.588, green: 0.529, blue: 0.502, alpha: 1.0)
        let selected   = UIColor(red: 0.482, green: 0.651, blue: 0.545, alpha: 1.0)

        appearance.stackedLayoutAppearance.normal.iconColor = unselected
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselected]
        appearance.stackedLayoutAppearance.selected.iconColor = selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selected]

        appearance.inlineLayoutAppearance.normal.iconColor = unselected
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselected]
        appearance.inlineLayoutAppearance.selected.iconColor = selected
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selected]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                TabView {
                    TodayView()
                        .tabItem {
                            Label("Today", systemImage: "sun.and.horizon")
                        }

                    FeedView()
                        .tabItem {
                            Label("Feed", systemImage: "clock.arrow.circlepath")
                        }

                    ProfileView()
                        .tabItem {
                            Label("Me", systemImage: "person.circle")
                        }
                }
                .tint(BeansColor.primary)
            } else {
                OnboardingContainerView()
            }
        }
        .onAppear {
            ChallengeLoader.loadInitialChallenges(context: modelContext)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Challenge.self, Attempt.self, UserProgress.self])
}
