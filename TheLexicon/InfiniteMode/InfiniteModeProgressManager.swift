//
//  InfiniteModeProgressManager.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - SwiftData Model

@Model
final class InfiniteModeProgress {
  var currentLevel: Int
  var completedLevels: Int
  var lastPlayedDate: Date

  init(currentLevel: Int = 1, completedLevels: Int = 0) {
    self.currentLevel = currentLevel
    self.completedLevels = completedLevels
    self.lastPlayedDate = Date()
  }
}

// MARK: - Progress Manager

@Observable
final class InfiniteModeProgressManager {

  private var modelContext: ModelContext?
  private var progress: InfiniteModeProgress?
  private let levelDatabase: LevelDatabase

  // MARK: - Initialization

  init(levelDatabase: LevelDatabase) {
    self.levelDatabase = levelDatabase
  }

  // MARK: - Computed Properties

  var currentLevel: Int {
    progress?.currentLevel ?? 1
  }

  var completedLevels: Int {
    progress?.completedLevels ?? 0
  }

  var currentDifficulty: InfiniteModeDifficulty {
    levelDatabase.difficulty(for: currentLevel)
  }

  var currentLevelData: InfiniteLevelData {
    levelDatabase.level(currentLevel)
  }

  // MARK: - Setup

  func configure(with modelContext: ModelContext) {
    self.modelContext = modelContext
    loadProgress()
  }

  // MARK: - Actions

  func completeCurrentLevel() {
    guard let progress else { return }

    progress.completedLevels += 1
    progress.currentLevel = min(progress.currentLevel + 1, LevelDatabase.totalLevels)
    progress.lastPlayedDate = Date()

    saveProgress()
  }

  func resetProgress() {
    guard let modelContext, let progress else { return }

    modelContext.delete(progress)
    self.progress = InfiniteModeProgress()
    modelContext.insert(self.progress!)

    saveProgress()
  }

  func setLevel(_ level: Int) {
    guard let progress else { return }

    let clampedLevel = max(1, min(level, LevelDatabase.totalLevels))
    progress.currentLevel = clampedLevel
    progress.lastPlayedDate = Date()

    saveProgress()
  }

  // MARK: - Private

  private func loadProgress() {
    guard let modelContext else { return }

    let descriptor = FetchDescriptor<InfiniteModeProgress>()

    do {
      let results = try modelContext.fetch(descriptor)

      if let existing = results.first {
        self.progress = existing
      } else {
        // Create initial progress
        let newProgress = InfiniteModeProgress()
        modelContext.insert(newProgress)
        self.progress = newProgress
        try? modelContext.save()
      }
    } catch {
      print("Failed to load infinite mode progress: \(error)")
    }
  }

  private func saveProgress() {
    try? modelContext?.save()
  }
}

// MARK: - Preview Support

extension InfiniteModeProgressManager {
  static func forPreview(level: Int = 1, completedLevels: Int = 0) -> InfiniteModeProgressManager {
    let manager = InfiniteModeProgressManager(levelDatabase: LevelDatabase())

    // Create an in-memory container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
      for: InfiniteModeProgress.self,
      configurations: config
    )
    let context = ModelContext(container)

    manager.configure(with: context)
    manager.progress?.currentLevel = level
    manager.progress?.completedLevels = completedLevels

    return manager
  }
}
