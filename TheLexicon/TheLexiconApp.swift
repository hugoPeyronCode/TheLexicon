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

  init() {
    do {
      modelContainer = try ModelContainer(for: DailyProgress.self, PuzzleState.self)
    } catch {
      fatalError("Failed to initialize ModelContainer: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      MainView()
        .onAppear {
          DailyProgressManager.shared.configure(with: modelContainer.mainContext)
          PuzzleStateManager.shared.configure(with: modelContainer.mainContext)
        }
    }
    .modelContainer(modelContainer)
  }
}
