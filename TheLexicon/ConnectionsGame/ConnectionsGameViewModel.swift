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

// MARK: - Swap State

struct SwapState: Equatable {
  let fromIndex: Int
  let toIndex: Int
}

// MARK: - ViewModel

@Observable
class ConnectionsGameViewModel {

  // MARK: - State

  var words: [Word] = []
  var selectedIndex: Int? = nil
  var completedRows: [CompletedRow] = []
  var isGameWon: Bool = false
  var recentlyCompletedRow: Int? = nil

  // Swap animation state
  var swapInProgress: SwapState? = nil
  var isSwapping: Bool = false

  // MARK: - Private State

  private var groups: [WordGroup] = []
  private let columns: Int = 4
  private let gameDate: Date

  // MARK: - Computed Properties

  var totalRows: Int {
    words.count / columns
  }

  var totalGroups: Int {
    groups.count
  }

  // MARK: - Initialization

  init(date: Date = Date()) {
    self.gameDate = Calendar.current.startOfDay(for: date)
    loadLevel()
  }

  // MARK: - Game Actions

  func selectCard(at index: Int) {
    guard index >= 0, index < words.count else { return }
    guard !isSwapping else { return }

    // Check if this row is already completed
    let row = index / columns
    if completedRows.contains(where: { $0.rowIndex == row }) {
      return
    }

    if let firstIndex = selectedIndex {
      if firstIndex == index {
        // Deselect if tapping same card
        selectedIndex = nil
      } else {
        // Perform swap
        performSwap(from: firstIndex, to: index)
      }
    } else {
      // Select this card
      selectedIndex = index
    }
  }

  private func performSwap(from firstIndex: Int, to secondIndex: Int) {
    isSwapping = true
    selectedIndex = nil

    // Set swap state - this triggers the animation
    swapInProgress = SwapState(fromIndex: firstIndex, toIndex: secondIndex)

    // After animation completes, swap the actual data and clear state
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
      guard let self else { return }

      // Swap data
      self.words.swapAt(firstIndex, secondIndex)

      // Clear swap state immediately (no animation for this)
      self.swapInProgress = nil
      self.isSwapping = false

      // Save current state
      self.savePuzzleState()

      // Check for completed rows
      self.checkForCompletedRows()
    }
  }

  func isSelected(at index: Int) -> Bool {
    selectedIndex == index
  }

  func isRowCompleted(_ row: Int) -> Bool {
    completedRows.contains { $0.rowIndex == row }
  }

  func completedRow(for row: Int) -> CompletedRow? {
    completedRows.first { $0.rowIndex == row }
  }

  func shuffleWords() {
    guard !isSwapping else { return }

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

    selectedIndex = nil

    // Save shuffled state
    savePuzzleState()
  }

  func restart() {
    // Clear saved puzzle state
    PuzzleStateManager.shared.clearState(for: gameDate)

    // Reset daily progress for this date
    DailyProgressManager.shared.updateProgress(
      for: gameDate,
      completedGroups: 0,
      totalGroups: groups.count
    )

    // Reload fresh level
    loadLevel(restoreState: false)
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
            PuzzleStateManager.shared.clearState(for: gameDate)
          }
        }
      }
    }
  }

  // MARK: - Progress Saving

  private func saveProgress() {
    DailyProgressManager.shared.updateProgress(
      for: gameDate,
      completedGroups: completedRows.count,
      totalGroups: groups.count
    )
  }

  // MARK: - Puzzle State Persistence

  private func savePuzzleState() {
    let wordOrder = words.map { $0.text }
    let completedIndices = completedRows.map { $0.rowIndex }

    PuzzleStateManager.shared.saveState(
      for: gameDate,
      wordOrder: wordOrder,
      completedRowIndices: completedIndices
    )
  }

  private func restorePuzzleState() -> Bool {
    guard let savedState = PuzzleStateManager.shared.loadState(for: gameDate) else {
      return false
    }

    // Verify the saved state matches current game (same words)
    let currentWordTexts = Set(words.map { $0.text })
    let savedWordTexts = Set(savedState.wordOrder)

    guard currentWordTexts == savedWordTexts,
          savedState.wordOrder.count == words.count else {
      // State doesn't match, clear it
      PuzzleStateManager.shared.clearState(for: gameDate)
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
      PuzzleStateManager.shared.clearState(for: gameDate)
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
    selectedIndex = nil
    completedRows.removeAll()
    isGameWon = false
    recentlyCompletedRow = nil
    swapInProgress = nil
    isSwapping = false

    // Load game data for the specific date
    groups = ConnectionsGameData.game(for: gameDate)

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
}
