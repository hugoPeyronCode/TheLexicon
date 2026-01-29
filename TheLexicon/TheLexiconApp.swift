//
//  TheLexiconApp.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI
import SwiftData

@main
struct TheLexiconApp: App {

  let modelContainer: ModelContainer
  let dependencies = AppDependencies()

  init() {
    do {
      modelContainer = try ModelContainer(
        for: DailyProgress.self,
        PuzzleState.self,
        InfiniteModeProgress.self,
        StreakData.self,
        VocabularyProfile.self,
        CategoryScore.self,
        WantToLearnWord.self
      )
    } catch {
      fatalError("Failed to initialize ModelContainer: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      MainView(dependencies: dependencies)
        .onAppear {
          dependencies.configure(with: modelContainer.mainContext)
        }
    }
    .modelContainer(modelContainer)
  }
}
