//
//  ConnectionsGameViewModel.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

// MARK: - Models

struct Word: Identifiable, Equatable {
  let id: UUID
  let text: String
  let groupId: UUID

  init(text: String, groupId: UUID) {
    self.id = UUID()
    self.text = text
    self.groupId = groupId
  }
}

struct WordGroup: Identifiable {
  let id: UUID
  let theme: String
  let words: [String]
  let color: Color

  init(theme: String, words: [String], color: Color) {
    self.id = UUID()
    self.theme = theme
    self.words = words
    self.color = color
  }
}

struct CompletedRow: Identifiable, Equatable {
  let id: UUID
  let rowIndex: Int
  let theme: String
  let words: [Word]
  let color: Color
}

// MARK: - ViewModel

@Observable
class ConnectionsGameViewModel {

  // MARK: - State

  var words: [Word] = []
  var completedRows: [CompletedRow] = []
  var isGameWon: Bool = false
  var recentlyCompletedRow: Int? = nil

  // Drag state
  var draggingIndex: Int? = nil

  // MARK: - Private State

  private var groups: [WordGroup] = []
  private let columns: Int = 4
  private let gameDate: Date?
  private let infiniteLevel: Int?
  private let customGroups: [WordGroup]?
  private let isCustomLevel: Bool

  // MARK: - Computed Properties

  var totalRows: Int {
    words.count / columns
  }

  var totalGroups: Int {
    groups.count
  }

  var isInfiniteMode: Bool {
    infiniteLevel != nil
  }

  // MARK: - Initialization

  init(date: Date = Date()) {
    self.gameDate = Calendar.current.startOfDay(for: date)
    self.infiniteLevel = nil
    self.customGroups = nil
    self.isCustomLevel = false
    loadLevel()
  }

  init(infiniteLevel: Int) {
    self.gameDate = nil
    self.infiniteLevel = infiniteLevel
    self.customGroups = nil
    self.isCustomLevel = false
    loadInfiniteLevel(infiniteLevel)
  }

  init(customGroups: [WordGroup]) {
    self.gameDate = nil
    self.infiniteLevel = nil
    self.customGroups = customGroups
    self.isCustomLevel = true
    loadCustomLevel(customGroups)
  }

  // MARK: - Game Actions

  func canDrag(index: Int) -> Bool {
    guard index >= 0, index < words.count else { return false }
    let row = index / columns
    return !completedRows.contains(where: { $0.rowIndex == row })
  }

  func canDrop(at index: Int) -> Bool {
    guard index >= 0, index < words.count else { return false }
    let row = index / columns
    return !completedRows.contains(where: { $0.rowIndex == row })
  }

  func performSwap(from firstIndex: Int, to secondIndex: Int) {
    guard firstIndex != secondIndex else { return }
    guard canDrag(index: firstIndex), canDrop(at: secondIndex) else { return }

    // Swap immediately
    words.swapAt(firstIndex, secondIndex)

    // Save current state
    savePuzzleState()

    // Check for completed rows
    checkForCompletedRows()
  }

  func isDragging(at index: Int) -> Bool {
    draggingIndex == index
  }

  func isRowCompleted(_ row: Int) -> Bool {
    completedRows.contains { $0.rowIndex == row }
  }

  func completedRow(for row: Int) -> CompletedRow? {
    completedRows.first { $0.rowIndex == row }
  }

  func shuffleWords() {
    // Only shuffle words that are not in completed rows
    let completedIndices = Set(completedRows.flatMap { row in
      (row.rowIndex * columns)..<(row.rowIndex * columns + columns)
    })

    var uncompletedWords: [Word] = []
    var uncompletedIndices: [Int] = []

    for (index, word) in words.enumerated() {
      if !completedIndices.contains(index) {
        uncompletedWords.append(word)
        uncompletedIndices.append(index)
      }
    }

    uncompletedWords.shuffle()

    for (i, index) in uncompletedIndices.enumerated() {
      words[index] = uncompletedWords[i]
    }

    // Save shuffled state
    savePuzzleState()
  }

  func restart() {
    if isInfiniteMode {
      // Reload infinite level
      if let level = infiniteLevel {
        loadInfiniteLevel(level)
      }
    } else if let date = gameDate {
      // Clear saved puzzle state
      PuzzleStateManager.shared.clearState(for: date)

      // Reset daily progress for this date
      DailyProgressManager.shared.updateProgress(
        for: date,
        completedGroups: 0,
        totalGroups: groups.count
      )

      // Reload fresh level
      loadLevel(restoreState: false)
    }
  }

  // MARK: - Row Checking

  private func checkForCompletedRows() {
    for row in 0..<totalRows {
      // Skip already completed rows
      if completedRows.contains(where: { $0.rowIndex == row }) {
        continue
      }

      let startIndex = row * columns
      let endIndex = startIndex + columns
      let rowWords = Array(words[startIndex..<endIndex])

      // Check if all words in this row belong to the same group
      let groupIds = Set(rowWords.map { $0.groupId })

      if groupIds.count == 1, let groupId = groupIds.first {
        // Row is complete!
        if let group = groups.first(where: { $0.id == groupId }) {
          let completed = CompletedRow(
            id: group.id,
            rowIndex: row,
            theme: group.theme,
            words: rowWords,
            color: group.color
          )
          completedRows.append(completed)
          recentlyCompletedRow = row

          // Save progress
          saveProgress()

          // Save puzzle state
          savePuzzleState()

          // Clear the animation trigger after a delay
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.recentlyCompletedRow = nil
          }

          // Check win condition
          if completedRows.count == groups.count {
            isGameWon = true
            // Clear puzzle state on win (completed puzzle doesn't need restoring)
            if let date = gameDate {
              PuzzleStateManager.shared.clearState(for: date)
            }
            // For infinite mode, advance to next level
            if isInfiniteMode {
              InfiniteModeProgressManager.shared.completeCurrentLevel()
            }
            // Award vocabulary points
            if isCustomLevel {
              recordCustomLevelProgress()
            } else {
              recordVocabularyProgress()
            }
          }
        }
      }
    }
  }

  // MARK: - Vocabulary Progress

  private func recordVocabularyProgress() {
    let themes = groups.map { $0.theme }
    let streakMultiplier = StreakManager.shared.currentStreak
    VocabularyProfileManager.shared.recordGameCompletion(
      themes: themes,
      streakMultiplier: streakMultiplier
    )
  }

  private func recordCustomLevelProgress() {
    // Get all word IDs from the custom level
    let wordIds = groups.flatMap { $0.words }.map { $0.lowercased() }
    VocabularyProfileManager.shared.recordPracticeLevelCompletion(wordIds: wordIds)
  }

  // MARK: - Progress Saving

  private func saveProgress() {
    guard let date = gameDate else { return }
    DailyProgressManager.shared.updateProgress(
      for: date,
      completedGroups: completedRows.count,
      totalGroups: groups.count
    )
  }

  // MARK: - Puzzle State Persistence

  private func savePuzzleState() {
    // Don't save state for infinite mode
    guard let date = gameDate else { return }

    let wordOrder = words.map { $0.text }
    let completedIndices = completedRows.map { $0.rowIndex }

    PuzzleStateManager.shared.saveState(
      for: date,
      wordOrder: wordOrder,
      completedRowIndices: completedIndices
    )
  }

  private func restorePuzzleState() -> Bool {
    guard let date = gameDate,
          let savedState = PuzzleStateManager.shared.loadState(for: date) else {
      return false
    }

    // Verify the saved state matches current game (same words)
    let currentWordTexts = Set(words.map { $0.text })
    let savedWordTexts = Set(savedState.wordOrder)

    guard currentWordTexts == savedWordTexts,
          savedState.wordOrder.count == words.count else {
      // State doesn't match, clear it
      if let date = gameDate {
        PuzzleStateManager.shared.clearState(for: date)
      }
      return false
    }

    // Create a mapping from word text to word object
    var wordsByText: [String: Word] = [:]
    for word in words {
      wordsByText[word.text] = word
    }

    // Restore word order
    var restoredWords: [Word] = []
    for text in savedState.wordOrder {
      if let word = wordsByText[text] {
        restoredWords.append(word)
      }
    }

    guard restoredWords.count == words.count else {
      if let date = gameDate {
        PuzzleStateManager.shared.clearState(for: date)
      }
      return false
    }

    words = restoredWords

    // Restore completed rows
    for rowIndex in savedState.completedRowIndices {
      let startIndex = rowIndex * columns
      let endIndex = startIndex + columns

      guard endIndex <= words.count else { continue }

      let rowWords = Array(words[startIndex..<endIndex])
      let groupIds = Set(rowWords.map { $0.groupId })

      // Verify row is actually complete
      if groupIds.count == 1, let groupId = groupIds.first {
        if let group = groups.first(where: { $0.id == groupId }) {
          let completed = CompletedRow(
            id: group.id,
            rowIndex: rowIndex,
            theme: group.theme,
            words: rowWords,
            color: group.color
          )
          completedRows.append(completed)
        }
      }
    }

    // Check if game was already won
    if completedRows.count == groups.count {
      isGameWon = true
    }

    return true
  }

  // MARK: - Level Loading

  private func loadLevel(restoreState: Bool = true) {
    guard let date = gameDate else { return }

    draggingIndex = nil
    completedRows.removeAll()
    isGameWon = false
    recentlyCompletedRow = nil

    // Load game data for the specific date
    groups = ConnectionsGameData.game(for: date)

    // Create word objects and shuffle
    words = groups.flatMap { group in
      group.words.map { Word(text: $0, groupId: group.id) }
    }
    words.shuffle()

    // Try to restore saved state if requested
    if restoreState {
      _ = restorePuzzleState()
    }
  }

  private func loadInfiniteLevel(_ level: Int) {
    draggingIndex = nil
    completedRows.removeAll()
    isGameWon = false
    recentlyCompletedRow = nil

    // Load game data for the infinite level
    let levelData = InfiniteModeData.level(level)
    groups = levelData.groups

    // Create word objects and shuffle
    words = groups.flatMap { group in
      group.words.map { Word(text: $0, groupId: group.id) }
    }
    words.shuffle()
  }

  private func loadCustomLevel(_ customGroups: [WordGroup]) {
    draggingIndex = nil
    completedRows.removeAll()
    isGameWon = false
    recentlyCompletedRow = nil

    groups = customGroups

    // Create word objects and shuffle
    words = groups.flatMap { group in
      group.words.map { Word(text: $0, groupId: group.id) }
    }
    words.shuffle()
  }
}
