//
//  PuzzleStateManager.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - SwiftData Model

@Model
final class PuzzleState {
  @Attribute(.unique) var date: Date

  // Store word order as array of word texts (preserves position)
  var wordOrder: [String]

  // Store completed row indices
  var completedRowIndices: [Int]

  init(date: Date, wordOrder: [String] = [], completedRowIndices: [Int] = []) {
    self.date = Calendar.current.startOfDay(for: date)
    self.wordOrder = wordOrder
    self.completedRowIndices = completedRowIndices
  }
}

// MARK: - Puzzle State Manager

@Observable
final class PuzzleStateManager {

  private var modelContext: ModelContext?
  private let calendar = Calendar.current

  // Cache for quick lookups
  private var stateCache: [Date: PuzzleState] = [:]

  // MARK: - Singleton

  static let shared = PuzzleStateManager()

  private init() {}

  // MARK: - Setup

  func configure(with modelContext: ModelContext) {
    self.modelContext = modelContext
    loadAllStates()
  }

  // MARK: - Public API

  func hasState(for date: Date) -> Bool {
    let normalizedDate = calendar.startOfDay(for: date)
    return stateCache[normalizedDate] != nil
  }

  func loadState(for date: Date) -> PuzzleState? {
    let normalizedDate = calendar.startOfDay(for: date)
    return stateCache[normalizedDate]
  }

  func saveState(for date: Date, wordOrder: [String], completedRowIndices: [Int]) {
    guard let modelContext else { return }

    let normalizedDate = calendar.startOfDay(for: date)

    if let existing = stateCache[normalizedDate] {
      // Update existing
      existing.wordOrder = wordOrder
      existing.completedRowIndices = completedRowIndices
    } else {
      // Create new
      let newState = PuzzleState(
        date: normalizedDate,
        wordOrder: wordOrder,
        completedRowIndices: completedRowIndices
      )
      modelContext.insert(newState)
      stateCache[normalizedDate] = newState
    }

    try? modelContext.save()
  }

  func clearState(for date: Date) {
    guard let modelContext else { return }

    let normalizedDate = calendar.startOfDay(for: date)

    if let existing = stateCache[normalizedDate] {
      modelContext.delete(existing)
      stateCache.removeValue(forKey: normalizedDate)
      try? modelContext.save()
    }
  }

  // MARK: - Private

  private func loadAllStates() {
    guard let modelContext else { return }

    let descriptor = FetchDescriptor<PuzzleState>()

    do {
      let allStates = try modelContext.fetch(descriptor)
      stateCache = Dictionary(uniqueKeysWithValues: allStates.map { ($0.date, $0) })
    } catch {
      print("Failed to load puzzle states: \(error)")
    }
  }
}
