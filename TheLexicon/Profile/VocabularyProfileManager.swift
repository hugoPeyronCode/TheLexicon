//
//  VocabularyProfileManager.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Semantic Categories

enum SemanticCategory: String, CaseIterable, Codable {
  case technology = "Technology"
  case arts = "Arts"
  case nature = "Nature"
  case history = "History"
  case science = "Science"
  case emotions = "Emotions"
  case business = "Business"
  case culture = "Culture"

  var icon: String {
    switch self {
    case .technology: return "cpu"
    case .arts: return "paintpalette"
    case .nature: return "leaf"
    case .history: return "book.closed"
    case .science: return "atom"
    case .emotions: return "heart"
    case .business: return "briefcase"
    case .culture: return "globe"
    }
  }

  var color: Color {
    switch self {
    case .technology: return .blue
    case .arts: return .purple
    case .nature: return .green
    case .history: return .brown
    case .science: return .cyan
    case .emotions: return .pink
    case .business: return .orange
    case .culture: return .indigo
    }
  }
}

// MARK: - Category Score Model

@Model
final class CategoryScore {
  var category: String // SemanticCategory rawValue
  var score: Int
  var wordsLearned: Int

  init(category: SemanticCategory, score: Int = 0, wordsLearned: Int = 0) {
    self.category = category.rawValue
    self.score = score
    self.wordsLearned = wordsLearned
  }

  var semanticCategory: SemanticCategory? {
    SemanticCategory(rawValue: category)
  }
}

// MARK: - Vocabulary Profile Model

@Model
final class VocabularyProfile {
  var overallScore: Int
  var vocabularyLevel: Int // 1-100 representing percentile
  var totalWordsLearned: Int
  var hasCompletedInitialTest: Bool
  var initialTestDate: Date?
  var lastUpdated: Date

  @Relationship(deleteRule: .cascade)
  var categoryScores: [CategoryScore]

  init() {
    self.overallScore = 0
    self.vocabularyLevel = 0
    self.totalWordsLearned = 0
    self.hasCompletedInitialTest = false
    self.initialTestDate = nil
    self.lastUpdated = Date()
    self.categoryScores = SemanticCategory.allCases.map { CategoryScore(category: $0) }
  }

  // Get score for a specific category
  func score(for category: SemanticCategory) -> Int {
    categoryScores.first { $0.category == category.rawValue }?.score ?? 0
  }

  // Get normalized scores (0-1) for spider graph
  func normalizedScores() -> [SemanticCategory: CGFloat] {
    var result: [SemanticCategory: CGFloat] = [:]
    let maxPossibleScore: CGFloat = 100

    for category in SemanticCategory.allCases {
      let score = CGFloat(self.score(for: category))
      result[category] = min(score / maxPossibleScore, 1.0)
    }

    return result
  }
}

// MARK: - Vocabulary Profile Manager

@Observable
final class VocabularyProfileManager {

  private var modelContext: ModelContext?
  private var profile: VocabularyProfile?

  // MARK: - Singleton

  static let shared = VocabularyProfileManager()

  private init() {}

  // MARK: - Computed Properties

  var overallScore: Int {
    profile?.overallScore ?? 0
  }

  var vocabularyLevel: Int {
    profile?.vocabularyLevel ?? 0
  }

  var totalWordsLearned: Int {
    profile?.totalWordsLearned ?? 0
  }

  var hasCompletedInitialTest: Bool {
    profile?.hasCompletedInitialTest ?? false
  }

  var categoryScores: [SemanticCategory: Int] {
    var result: [SemanticCategory: Int] = [:]
    for category in SemanticCategory.allCases {
      result[category] = profile?.score(for: category) ?? 0
    }
    return result
  }

  var normalizedCategoryScores: [SemanticCategory: CGFloat] {
    profile?.normalizedScores() ?? [:]
  }

  // MARK: - Setup

  func configure(with modelContext: ModelContext) {
    self.modelContext = modelContext
    loadProfile()
  }

  // MARK: - Initial Test

  func completeInitialTest(score: Int, categoryScores: [SemanticCategory: Int]) {
    guard let profile else { return }

    profile.hasCompletedInitialTest = true
    profile.initialTestDate = Date()
    profile.overallScore = score
    profile.vocabularyLevel = calculateLevel(from: score)

    // Set initial category scores
    for (category, categoryScore) in categoryScores {
      if let existing = profile.categoryScores.first(where: { $0.category == category.rawValue }) {
        existing.score = categoryScore
      }
    }

    profile.lastUpdated = Date()
    saveData()
  }

  // MARK: - Game Completion Rewards

  /// Call when a game is completed to award vocabulary points
  func recordGameCompletion(
    themes: [String],
    streakMultiplier: Int = 1
  ) {
    guard let profile else { return }

    // Base points for completing a game
    let basePoints = 5
    let streakBonus = min(streakMultiplier, 7) // Cap at 7x
    let totalPoints = basePoints * streakBonus

    // Update overall score
    profile.overallScore += totalPoints
    profile.totalWordsLearned += themes.count * 4 // 4 words per theme

    // Map themes to categories and award category points
    for theme in themes {
      if let category = mapThemeToCategory(theme) {
        if let categoryScore = profile.categoryScores.first(where: { $0.category == category.rawValue }) {
          categoryScore.score += (basePoints / 2) * streakBonus
          categoryScore.wordsLearned += 4
        }
      }
    }

    // Recalculate vocabulary level
    profile.vocabularyLevel = calculateLevel(from: profile.overallScore)
    profile.lastUpdated = Date()

    saveData()
  }

  /// Call when a practice level with "want to learn" words is completed
  func recordPracticeLevelCompletion(wordIds: [String]) {
    guard let profile else { return }

    // Award bonus points for practicing marked words
    let bonusPoints = 10

    // Update overall score
    profile.overallScore += bonusPoints
    profile.totalWordsLearned += wordIds.count

    // Award category points based on the words
    for wordId in wordIds {
      if let definition = WordDatabase.shared.definition(for: wordId),
         let category = SemanticCategory(rawValue: definition.category) {
        if let categoryScore = profile.categoryScores.first(where: { $0.category == category.rawValue }) {
          categoryScore.score += 2
          categoryScore.wordsLearned += 1
        }
      }
    }

    // Recalculate vocabulary level
    profile.vocabularyLevel = calculateLevel(from: profile.overallScore)
    profile.lastUpdated = Date()

    saveData()

    // Mark words as learned in WantToLearnManager
    for wordId in wordIds {
      WantToLearnManager.shared.markAsLearned(wordId)
    }
  }

  // MARK: - Private Helpers

  private func calculateLevel(from score: Int) -> Int {
    // Logarithmic scaling: higher scores = diminishing level gains
    // Level 1-100 scale
    let level = Int(log10(Double(max(score, 1)) + 1) * 30)
    return min(max(level, 1), 100)
  }

  private func mapThemeToCategory(_ theme: String) -> SemanticCategory? {
    let themeLower = theme.lowercased()

    // Technology
    if ["technology", "computers", "software", "programming", "digital", "internet", "tech", "devices", "programming paradigms", "typography", "cryptography"].contains(where: { themeLower.contains($0) }) {
      return .technology
    }

    // Arts
    if ["art", "music", "painting", "dance", "film", "theater", "poetry", "literature", "renaissance", "jazz", "instruments", "shakespeare", "literary"].contains(where: { themeLower.contains($0) }) {
      return .arts
    }

    // Nature
    if ["nature", "animals", "plants", "tree", "flower", "ocean", "bird", "insect", "weather", "season", "cloud", "volcanic", "gems", "metals"].contains(where: { themeLower.contains($0) }) {
      return .nature
    }

    // History
    if ["history", "ancient", "war", "empire", "dynasty", "wonders", "greek", "roman", "medieval"].contains(where: { themeLower.contains($0) }) {
      return .history
    }

    // Science
    if ["science", "physics", "chemistry", "biology", "math", "astronomy", "planet", "atom", "scientific", "geometry", "nobel"].contains(where: { themeLower.contains($0) }) {
      return .science
    }

    // Emotions
    if ["emotion", "feeling", "happy", "sad", "love", "fear", "psychological", "family", "relationship"].contains(where: { themeLower.contains($0) }) {
      return .emotions
    }

    // Business
    if ["business", "money", "economy", "finance", "work", "job", "career", "economic", "legal", "poker"].contains(where: { themeLower.contains($0) }) {
      return .business
    }

    // Culture
    if ["culture", "food", "cuisine", "language", "country", "travel", "religion", "philosophy", "wine", "coffee", "pasta", "cocktail", "cheese", "spice", "dessert"].contains(where: { themeLower.contains($0) }) {
      return .culture
    }

    // Default: distribute to a random category or nil
    return nil
  }

  private func loadProfile() {
    guard let modelContext else { return }

    let descriptor = FetchDescriptor<VocabularyProfile>()

    do {
      let results = try modelContext.fetch(descriptor)

      if let existing = results.first {
        self.profile = existing
      } else {
        // Create initial profile
        let newProfile = VocabularyProfile()
        modelContext.insert(newProfile)
        self.profile = newProfile
        try? modelContext.save()
      }
    } catch {
      print("Failed to load vocabulary profile: \(error)")
    }
  }

  private func saveData() {
    try? modelContext?.save()
  }
}

// MARK: - Preview Support

extension VocabularyProfileManager {
  static func forPreview(
    overallScore: Int = 250,
    hasCompletedTest: Bool = true,
    categoryScores: [SemanticCategory: Int]? = nil
  ) -> VocabularyProfileManager {
    let manager = VocabularyProfileManager()

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
      for: VocabularyProfile.self, CategoryScore.self,
      configurations: config
    )
    let context = ModelContext(container)

    manager.configure(with: context)

    if hasCompletedTest {
      let scores = categoryScores ?? [
        .technology: 45,
        .arts: 60,
        .nature: 75,
        .history: 30,
        .science: 55,
        .emotions: 80,
        .business: 40,
        .culture: 65
      ]
      manager.completeInitialTest(score: overallScore, categoryScores: scores)
    }

    return manager
  }
}
