//
//  DailyProgressManager.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - SwiftData Model

@Model
final class DailyProgress {
  @Attribute(.unique) var date: Date
  var completedGroups: Int
  var totalGroups: Int

  var isCompleted: Bool {
    completedGroups >= totalGroups && totalGroups > 0
  }

  var progress: CGFloat {
    guard totalGroups > 0 else { return 0 }
    return CGFloat(completedGroups) / CGFloat(totalGroups)
  }

  init(date: Date, completedGroups: Int = 0, totalGroups: Int = 4) {
    self.date = Calendar.current.startOfDay(for: date)
    self.completedGroups = completedGroups
    self.totalGroups = totalGroups
  }
}

// MARK: - Progress Manager

@Observable
final class DailyProgressManager {

  private var modelContext: ModelContext?
  private let calendar = Calendar.current

  // Cache for quick lookups
  private var progressCache: [Date: DailyProgress] = [:]

  // MARK: - Initialization

  init() {}

  // MARK: - Setup

  func configure(with modelContext: ModelContext) {
    self.modelContext = modelContext
    loadAllProgress()
  }

  // MARK: - Public API

  func progress(for date: Date) -> DailyProgress {
    let normalizedDate = calendar.startOfDay(for: date)

    if let cached = progressCache[normalizedDate] {
      return cached
    }

    // Create a new one if not found
    let newProgress = DailyProgress(date: normalizedDate)
    return newProgress
  }

  func completedCount(for date: Date) -> Int {
    progress(for: date).completedGroups
  }

  func totalCount(for date: Date) -> Int {
    progress(for: date).totalGroups
  }

  func isCompleted(for date: Date) -> Bool {
    progress(for: date).isCompleted
  }

  func updateProgress(for date: Date, completedGroups: Int, totalGroups: Int) {
    guard let modelContext else { return }

    let normalizedDate = calendar.startOfDay(for: date)

    if let existing = progressCache[normalizedDate] {
      // Update existing
      existing.completedGroups = completedGroups
      existing.totalGroups = totalGroups
    } else {
      // Create new
      let newProgress = DailyProgress(
        date: normalizedDate,
        completedGroups: completedGroups,
        totalGroups: totalGroups
      )
      modelContext.insert(newProgress)
      progressCache[normalizedDate] = newProgress
    }

    try? modelContext.save()
  }

  func markCompleted(for date: Date) {
    let current = progress(for: date)
    updateProgress(for: date, completedGroups: current.totalGroups, totalGroups: current.totalGroups)
  }

  func resetProgress(for date: Date) {
    guard let modelContext else { return }

    let normalizedDate = calendar.startOfDay(for: date)

    if let existing = progressCache[normalizedDate] {
      modelContext.delete(existing)
      progressCache.removeValue(forKey: normalizedDate)
      try? modelContext.save()
    }
  }

  // MARK: - Private

  private func loadAllProgress() {
    guard let modelContext else { return }

    let descriptor = FetchDescriptor<DailyProgress>()

    do {
      let allProgress = try modelContext.fetch(descriptor)
      progressCache = Dictionary(uniqueKeysWithValues: allProgress.map { ($0.date, $0) })
    } catch {
      print("Failed to load progress: \(error)")
    }
  }
}

// MARK: - Preview Support

extension DailyProgressManager {
  static func forPreview() -> DailyProgressManager {
    let manager = DailyProgressManager()

    // Create an in-memory container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyProgress.self, configurations: config)
    let context = ModelContext(container)

    manager.configure(with: context)

    // Add sample data for previews
    let today = Calendar.current.startOfDay(for: Date())

    // Yesterday - completed
    if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) {
      manager.updateProgress(for: yesterday, completedGroups: 4, totalGroups: 4)
    }

    // Two days ago - partial
    if let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today) {
      manager.updateProgress(for: twoDaysAgo, completedGroups: 2, totalGroups: 4)
    }

    // Today - in progress
    manager.updateProgress(for: today, completedGroups: 1, totalGroups: 4)

    return manager
  }
}

