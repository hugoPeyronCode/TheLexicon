//
//  StreakManager.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - SwiftData Model

@Model
final class StreakData {
  var currentStreak: Int
  var longestStreak: Int
  var lastCompletedDate: Date?
  var todayCompleted: Bool

  init(
    currentStreak: Int = 0,
    longestStreak: Int = 0,
    lastCompletedDate: Date? = nil,
    todayCompleted: Bool = false
  ) {
    self.currentStreak = currentStreak
    self.longestStreak = longestStreak
    self.lastCompletedDate = lastCompletedDate
    self.todayCompleted = todayCompleted
  }
}

// MARK: - Streak Manager

@Observable
final class StreakManager {

  private var modelContext: ModelContext?
  private var streakData: StreakData?
  private let calendar = Calendar.current

  // MARK: - Singleton

  static let shared = StreakManager()

  private init() {}

  // MARK: - Computed Properties

  var currentStreak: Int {
    validateAndUpdateStreak()
    return streakData?.currentStreak ?? 0
  }

  var longestStreak: Int {
    streakData?.longestStreak ?? 0
  }

  var isTodayCompleted: Bool {
    validateAndUpdateStreak()
    return streakData?.todayCompleted ?? false
  }

  var lastCompletedDate: Date? {
    streakData?.lastCompletedDate
  }

  // MARK: - Setup

  func configure(with modelContext: ModelContext) {
    self.modelContext = modelContext
    loadStreakData()
    validateAndUpdateStreak()
  }

  // MARK: - Actions

  /// Call this when user completes a game (daily or infinite)
  /// Returns true if this is a new streak day (first completion today)
  @discardableResult
  func recordCompletion() -> Bool {
    guard let streakData else { return false }

    let today = calendar.startOfDay(for: Date())

    // Already completed today
    if streakData.todayCompleted,
       let lastDate = streakData.lastCompletedDate,
       calendar.isDate(lastDate, inSameDayAs: today) {
      return false
    }

    // Check if we're continuing a streak or starting fresh
    if let lastDate = streakData.lastCompletedDate {
      let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

      if calendar.isDate(lastDate, inSameDayAs: yesterday) {
        // Continuing streak from yesterday
        streakData.currentStreak += 1
      } else if calendar.isDate(lastDate, inSameDayAs: today) {
        // Already counted today (shouldn't reach here but safety check)
        return false
      } else {
        // Streak was broken, start fresh
        streakData.currentStreak = 1
      }
    } else {
      // First ever completion
      streakData.currentStreak = 1
    }

    // Update longest streak if needed
    if streakData.currentStreak > streakData.longestStreak {
      streakData.longestStreak = streakData.currentStreak
    }

    streakData.lastCompletedDate = today
    streakData.todayCompleted = true

    saveData()
    return true
  }

  /// Validates streak state (called on app launch / day change)
  private func validateAndUpdateStreak() {
    guard let streakData else { return }

    let today = calendar.startOfDay(for: Date())

    guard let lastDate = streakData.lastCompletedDate else {
      // No history, nothing to validate
      return
    }

    // Check if todayCompleted flag needs reset (new day)
    if !calendar.isDate(lastDate, inSameDayAs: today) {
      streakData.todayCompleted = false

      // Check if streak is broken (more than 1 day gap)
      let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
      if !calendar.isDate(lastDate, inSameDayAs: yesterday) {
        // Streak is broken
        streakData.currentStreak = 0
      }

      saveData()
    }
  }

  // MARK: - Private

  private func loadStreakData() {
    guard let modelContext else { return }

    let descriptor = FetchDescriptor<StreakData>()

    do {
      let results = try modelContext.fetch(descriptor)

      if let existing = results.first {
        self.streakData = existing
      } else {
        // Create initial streak data
        let newData = StreakData()
        modelContext.insert(newData)
        self.streakData = newData
        try? modelContext.save()
      }
    } catch {
      print("Failed to load streak data: \(error)")
    }
  }

  private func saveData() {
    try? modelContext?.save()
  }
}

// MARK: - Preview Support

extension StreakManager {
  static func forPreview(streak: Int = 7, todayCompleted: Bool = true) -> StreakManager {
    let manager = StreakManager()

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StreakData.self, configurations: config)
    let context = ModelContext(container)

    manager.configure(with: context)
    manager.streakData?.currentStreak = streak
    manager.streakData?.longestStreak = max(streak, 10)
    manager.streakData?.todayCompleted = todayCompleted
    if todayCompleted {
      manager.streakData?.lastCompletedDate = Date()
    }

    return manager
  }
}
