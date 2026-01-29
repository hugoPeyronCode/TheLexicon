//
//  WantToLearnManager.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - SwiftData Model

@Model
final class WantToLearnWord {
  @Attribute(.unique) var wordId: String
  var addedDate: Date
  var learned: Bool
  var learnedDate: Date?

  init(wordId: String, addedDate: Date = Date(), learned: Bool = false, learnedDate: Date? = nil) {
    self.wordId = wordId
    self.addedDate = addedDate
    self.learned = learned
    self.learnedDate = learnedDate
  }
}

// MARK: - Manager

@Observable
final class WantToLearnManager {

  private var modelContext: ModelContext?
  private let wordDatabase: WordDatabase

  // Cache for quick lookups
  private var wordsCache: [String: WantToLearnWord] = [:]

  // Minimum words needed to create a custom level
  static let minimumWordsForLevel = 16

  // MARK: - Initialization

  init(wordDatabase: WordDatabase) {
    self.wordDatabase = wordDatabase
  }

  // MARK: - Setup

  func configure(with modelContext: ModelContext) {
    self.modelContext = modelContext
    loadAllWords()
  }

  // MARK: - Public API

  /// All words marked as "want to learn"
  var allWords: [WantToLearnWord] {
    Array(wordsCache.values).sorted { $0.addedDate > $1.addedDate }
  }

  /// Words not yet learned
  var pendingWords: [WantToLearnWord] {
    allWords.filter { !$0.learned }
  }

  /// Words that have been learned
  var learnedWords: [WantToLearnWord] {
    allWords.filter { $0.learned }
  }

  /// Count of pending words
  var pendingCount: Int {
    pendingWords.count
  }

  /// Whether we have enough words for a custom level
  var canCreateCustomLevel: Bool {
    pendingCount >= Self.minimumWordsForLevel
  }

  /// Check if a word is in the "want to learn" list
  func isMarked(_ wordId: String) -> Bool {
    wordsCache[wordId] != nil
  }

  /// Check if a word has been learned
  func isLearned(_ wordId: String) -> Bool {
    wordsCache[wordId]?.learned ?? false
  }

  /// Add a word to the "want to learn" list
  func markWord(_ wordId: String) {
    guard let modelContext, !isMarked(wordId) else { return }

    let word = WantToLearnWord(wordId: wordId)
    modelContext.insert(word)
    wordsCache[wordId] = word

    try? modelContext.save()
  }

  /// Remove a word from the "want to learn" list
  func unmarkWord(_ wordId: String) {
    guard let modelContext, let word = wordsCache[wordId] else { return }

    modelContext.delete(word)
    wordsCache.removeValue(forKey: wordId)

    try? modelContext.save()
  }

  /// Toggle the "want to learn" status
  func toggleWord(_ wordId: String) {
    if isMarked(wordId) {
      unmarkWord(wordId)
    } else {
      markWord(wordId)
    }
  }

  /// Mark a word as learned
  func markAsLearned(_ wordId: String) {
    guard let modelContext, let word = wordsCache[wordId] else { return }

    word.learned = true
    word.learnedDate = Date()

    try? modelContext.save()
  }

  /// Get words for a custom level (takes the oldest pending words)
  func wordsForCustomLevel(count: Int = 16) -> [String] {
    let pending = pendingWords.sorted { $0.addedDate < $1.addedDate }
    return Array(pending.prefix(count)).map { $0.wordId }
  }

  /// Generate custom word groups for a practice level
  /// Groups are created based on category or random groupings
  func generateCustomLevel() -> [WordGroup] {
    let wordIds = wordsForCustomLevel()
    let definitions = wordIds.compactMap { wordDatabase.definition(for: $0) }

    // Group by category first
    var wordsByCategory: [String: [WordDefinition]] = [:]
    for word in definitions {
      wordsByCategory[word.category, default: []].append(word)
    }

    var groups: [WordGroup] = []
    var usedWords: Set<String> = []

    // Create groups from categories that have 4+ words
    for (category, words) in wordsByCategory {
      if words.count >= 4 {
        let groupWords = Array(words.prefix(4))
        let color = SemanticCategory(rawValue: category)?.color ?? .gray

        let group = WordGroup(
          theme: "Words to Learn: \(category)",
          words: groupWords.map { $0.word },
          color: color
        )
        groups.append(group)

        for word in groupWords {
          usedWords.insert(word.id)
        }

        if groups.count >= 4 { break }
      }
    }

    // If we don't have enough groups, create mixed groups
    if groups.count < 4 {
      let remainingWords = definitions.filter { !usedWords.contains($0.id) }
      var mixedWords = remainingWords.shuffled()

      let mixColors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal]
      var colorIndex = 0

      while groups.count < 4 && mixedWords.count >= 4 {
        let groupWords = Array(mixedWords.prefix(4))
        mixedWords = Array(mixedWords.dropFirst(4))

        let group = WordGroup(
          theme: "Practice Group \(groups.count + 1)",
          words: groupWords.map { $0.word },
          color: mixColors[colorIndex % mixColors.count]
        )
        groups.append(group)
        colorIndex += 1
      }
    }

    return groups
  }

  /// Clear all words (for debug/reset)
  func clearAll() {
    guard let modelContext else { return }

    for word in wordsCache.values {
      modelContext.delete(word)
    }
    wordsCache.removeAll()

    try? modelContext.save()
  }

  // MARK: - Private

  private func loadAllWords() {
    guard let modelContext else { return }

    let descriptor = FetchDescriptor<WantToLearnWord>()

    do {
      let allWords = try modelContext.fetch(descriptor)
      wordsCache = Dictionary(uniqueKeysWithValues: allWords.map { ($0.wordId, $0) })
    } catch {
      print("Failed to load want to learn words: \(error)")
    }
  }
}

// MARK: - Preview Support

extension WantToLearnManager {
  static func forPreview(wordDatabase: WordDatabase = WordDatabase()) -> WantToLearnManager {
    let manager = WantToLearnManager(wordDatabase: wordDatabase)

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WantToLearnWord.self, configurations: config)
    let context = ModelContext(container)

    manager.configure(with: context)

    // Add some sample words
    manager.markWord("ephemeral")
    manager.markWord("sycophant")
    manager.markWord("ubiquitous")
    manager.markWord("ameliorate")

    return manager
  }
}
