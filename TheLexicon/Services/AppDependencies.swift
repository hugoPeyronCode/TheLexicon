//
//  AppDependencies.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 29/01/2026.
//

import SwiftUI
import SwiftData

/// Central dependency container for the app.
/// All managers are created here and injected throughout the app.
@Observable
final class AppDependencies {

  // MARK: - Databases (read-only, no SwiftData)

  let wordDatabase: WordDatabase
  let levelDatabase: LevelDatabase

  // MARK: - Managers (stateful, require SwiftData)

  let dailyProgressManager: DailyProgressManager
  let puzzleStateManager: PuzzleStateManager
  let streakManager: StreakManager
  let infiniteModeProgressManager: InfiniteModeProgressManager
  let wantToLearnManager: WantToLearnManager
  let vocabularyProfileManager: VocabularyProfileManager

  // MARK: - Theme

  let colorManager: AppColorManager
  let fontManager: AppFontManager

  // MARK: - Initialization

  init() {
    // Create databases
    wordDatabase = WordDatabase()
    levelDatabase = LevelDatabase()

    // Create theme managers and set as current for static access
    colorManager = AppColorManager()
    fontManager = AppFontManager()
    AppColorManager.current = colorManager
    AppFontManager.current = fontManager

    // Create data managers
    dailyProgressManager = DailyProgressManager()
    puzzleStateManager = PuzzleStateManager()
    streakManager = StreakManager()
    infiniteModeProgressManager = InfiniteModeProgressManager(levelDatabase: levelDatabase)

    // Create managers with dependencies
    wantToLearnManager = WantToLearnManager(wordDatabase: wordDatabase)
    vocabularyProfileManager = VocabularyProfileManager(
      wordDatabase: wordDatabase,
      wantToLearnManager: wantToLearnManager
    )
  }

  // MARK: - Configuration

  /// Configure all managers with the SwiftData ModelContext.
  /// Call this in onAppear of the root view.
  func configure(with modelContext: ModelContext) {
    dailyProgressManager.configure(with: modelContext)
    puzzleStateManager.configure(with: modelContext)
    streakManager.configure(with: modelContext)
    infiniteModeProgressManager.configure(with: modelContext)
    wantToLearnManager.configure(with: modelContext)
    vocabularyProfileManager.configure(with: modelContext)
  }

  // MARK: - Preview Support

  static func forPreview() -> AppDependencies {
    let deps = AppDependencies()

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
      for: DailyProgress.self,
      PuzzleState.self,
      InfiniteModeProgress.self,
      StreakData.self,
      VocabularyProfile.self,
      CategoryScore.self,
      WantToLearnWord.self,
      configurations: config
    )

    deps.configure(with: container.mainContext)

    // Add sample data
    let today = Calendar.current.startOfDay(for: Date())

    // Sample progress
    if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) {
      deps.dailyProgressManager.updateProgress(for: yesterday, completedGroups: 4, totalGroups: 4)
    }
    deps.dailyProgressManager.updateProgress(for: today, completedGroups: 2, totalGroups: 4)

    // Sample streak
    deps.streakManager.recordCompletion()

    // Sample vocabulary
    deps.vocabularyProfileManager.completeInitialTest(
      score: 250,
      categoryScores: [
        .technology: 45,
        .arts: 60,
        .nature: 75,
        .history: 30,
        .science: 55,
        .emotions: 80,
        .business: 40,
        .culture: 65
      ]
    )

    return deps
  }
}
