//
//  LevelDatabase.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import Foundation

// MARK: - Level Database

@Observable
final class LevelDatabase {

  // MARK: - Singleton

  static let shared = LevelDatabase()

  // MARK: - Properties

  private var levels: [Int: LevelJSON] = [:]
  private var isLoaded = false

  static let totalLevels = 500

  // Reference date for daily game calculation (Jan 1, 2026)
  private static let referenceDate: Date = {
    var components = DateComponents()
    components.year = 2026
    components.month = 1
    components.day = 1
    return Calendar.current.date(from: components) ?? Date()
  }()

  // MARK: - Initialization

  private init() {
    loadAllLevels()
  }

  // MARK: - Public API

  /// Returns level data for a specific level number (1-500)
  func level(_ number: Int) -> InfiniteLevelData {
    // Ensure level is within valid range, loop if needed
    let adjustedLevel = ((number - 1) % Self.totalLevels) + 1

    if let levelData = levels[adjustedLevel] {
      return levelData.toInfiniteLevelData()
    }

    // Fallback to generated level if not found
    return generateFallbackLevel(for: adjustedLevel)
  }

  /// Returns word groups for a specific date (daily game)
  func groups(for date: Date) -> [WordGroup] {
    let levelNumber = levelNumber(for: date)
    return level(levelNumber).groups
  }

  /// Calculate level number for a given date
  func levelNumber(for date: Date) -> Int {
    let calendar = Calendar.current
    let targetDate = calendar.startOfDay(for: date)
    let reference = calendar.startOfDay(for: Self.referenceDate)

    let daysDifference = calendar.dateComponents([.day], from: reference, to: targetDate).day ?? 0
    let adjustedDays = abs(daysDifference)

    return (adjustedDays % Self.totalLevels) + 1
  }

  /// Returns difficulty for a specific level
  func difficulty(for levelNumber: Int) -> InfiniteModeDifficulty {
    let adjustedLevel = ((levelNumber - 1) % 10) + 1

    switch adjustedLevel {
    case 1...2:
      return .easy
    case 3...5:
      return .medium
    case 6...8:
      return .hard
    case 9...10:
      return .expert
    default:
      return .easy
    }
  }

  // MARK: - Loading

  private func loadAllLevels() {
    guard !isLoaded else { return }

    // Load from bundled JSON files (50 levels per file)
    let fileNames = stride(from: 1, through: 500, by: 50).map { start -> String in
      let end = min(start + 49, 500)
      return String(format: "levels_%03d_%03d", start, end)
    }

    for fileName in fileNames {
      loadLevelFile(named: fileName)
    }

    isLoaded = true

    // If no JSON files found, generate fallback data
    if levels.isEmpty {
      generateAllFallbackLevels()
    }
  }

  private func loadLevelFile(named name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
      return
    }

    do {
      let decoder = JSONDecoder()
      let fileData = try decoder.decode(LevelFileData.self, from: data)

      for level in fileData.levels {
        levels[level.id] = level
      }
    } catch {
      print("Failed to decode \(name).json: \(error)")
    }
  }

  // MARK: - Fallback Generation

  private func generateAllFallbackLevels() {
    for i in 1...Self.totalLevels {
      levels[i] = generateFallbackLevelJSON(for: i)
    }
  }

  private func generateFallbackLevelJSON(for number: Int) -> LevelJSON {
    let difficulty = self.difficulty(for: number)
    let groupCount = groupCount(for: difficulty)
    let groups = generateGroups(count: groupCount, levelNumber: number)

    return LevelJSON(
      id: number,
      groups: groups,
      difficulty: difficulty.rawValue.lowercased()
    )
  }

  private func generateFallbackLevel(for number: Int) -> InfiniteLevelData {
    let levelJSON = generateFallbackLevelJSON(for: number)
    return levelJSON.toInfiniteLevelData()
  }

  private func groupCount(for difficulty: InfiniteModeDifficulty) -> Int {
    switch difficulty {
    case .easy: return 4
    case .medium: return [5, 6].randomElement()!
    case .hard: return [6, 7, 8].randomElement()!
    case .expert: return [9, 10].randomElement()!
    }
  }

  private func generateGroups(count: Int, levelNumber: Int) -> [GroupJSON] {
    let allThemes = FallbackThemes.all
    let seed = levelNumber * 31 // Deterministic selection based on level
    var usedIndices: Set<Int> = []
    var groups: [GroupJSON] = []

    for i in 0..<count {
      var index = (seed + i * 17) % allThemes.count
      while usedIndices.contains(index) {
        index = (index + 1) % allThemes.count
      }
      usedIndices.insert(index)
      groups.append(allThemes[index])
    }

    return groups
  }
}

// MARK: - Fallback Themes

private enum FallbackThemes {
  static let all: [GroupJSON] = [
    // Technology
    GroupJSON(theme: "Programming Languages", words: ["Python", "Java", "Swift", "Rust"], color: "blue", category: "Technology"),
    GroupJSON(theme: "Web Technologies", words: ["HTML", "CSS", "JavaScript", "React"], color: "cyan", category: "Technology"),
    GroupJSON(theme: "Operating Systems", words: ["Windows", "MacOS", "Linux", "Android"], color: "blue", category: "Technology"),
    GroupJSON(theme: "Social Media", words: ["Twitter", "Instagram", "TikTok", "Facebook"], color: "indigo", category: "Technology"),
    GroupJSON(theme: "Tech Companies", words: ["Apple", "Google", "Microsoft", "Amazon"], color: "gray", category: "Technology"),

    // Arts
    GroupJSON(theme: "Art Movements", words: ["Impressionism", "Cubism", "Surrealism", "Baroque"], color: "purple", category: "Arts"),
    GroupJSON(theme: "Musical Instruments", words: ["Piano", "Violin", "Guitar", "Drums"], color: "orange", category: "Arts"),
    GroupJSON(theme: "Literary Genres", words: ["Fantasy", "Mystery", "Romance", "Horror"], color: "purple", category: "Arts"),
    GroupJSON(theme: "Famous Painters", words: ["Picasso", "Monet", "Van Gogh", "Rembrandt"], color: "pink", category: "Arts"),
    GroupJSON(theme: "Dance Styles", words: ["Ballet", "Tango", "Salsa", "Hip-hop"], color: "red", category: "Arts"),

    // Nature
    GroupJSON(theme: "Wild Animals", words: ["Lion", "Tiger", "Bear", "Wolf"], color: "orange", category: "Nature"),
    GroupJSON(theme: "Tree Types", words: ["Oak", "Maple", "Pine", "Birch"], color: "green", category: "Nature"),
    GroupJSON(theme: "Ocean Creatures", words: ["Whale", "Dolphin", "Shark", "Octopus"], color: "blue", category: "Nature"),
    GroupJSON(theme: "Birds", words: ["Eagle", "Owl", "Hawk", "Crow"], color: "brown", category: "Nature"),
    GroupJSON(theme: "Flowers", words: ["Rose", "Tulip", "Lily", "Daisy"], color: "pink", category: "Nature"),
    GroupJSON(theme: "Weather Phenomena", words: ["Thunder", "Lightning", "Tornado", "Hurricane"], color: "gray", category: "Nature"),
    GroupJSON(theme: "Precious Gems", words: ["Diamond", "Ruby", "Emerald", "Sapphire"], color: "cyan", category: "Nature"),

    // History
    GroupJSON(theme: "Ancient Civilizations", words: ["Egypt", "Rome", "Greece", "Persia"], color: "brown", category: "History"),
    GroupJSON(theme: "Historical Figures", words: ["Napoleon", "Caesar", "Cleopatra", "Alexander"], color: "red", category: "History"),
    GroupJSON(theme: "World Wars", words: ["Normandy", "Stalingrad", "Pearl Harbor", "Hiroshima"], color: "gray", category: "History"),
    GroupJSON(theme: "Explorers", words: ["Columbus", "Magellan", "Cook", "Polo"], color: "blue", category: "History"),
    GroupJSON(theme: "Greek Mythology", words: ["Zeus", "Athena", "Poseidon", "Apollo"], color: "purple", category: "History"),

    // Science
    GroupJSON(theme: "Chemical Elements", words: ["Oxygen", "Hydrogen", "Carbon", "Nitrogen"], color: "cyan", category: "Science"),
    GroupJSON(theme: "Planets", words: ["Mars", "Venus", "Jupiter", "Saturn"], color: "indigo", category: "Science"),
    GroupJSON(theme: "Scientists", words: ["Einstein", "Newton", "Darwin", "Curie"], color: "blue", category: "Science"),
    GroupJSON(theme: "Body Organs", words: ["Heart", "Lungs", "Brain", "Liver"], color: "red", category: "Science"),
    GroupJSON(theme: "Physics Terms", words: ["Gravity", "Momentum", "Friction", "Velocity"], color: "purple", category: "Science"),

    // Emotions
    GroupJSON(theme: "Positive Emotions", words: ["Joy", "Love", "Hope", "Peace"], color: "yellow", category: "Emotions"),
    GroupJSON(theme: "Negative Emotions", words: ["Anger", "Fear", "Sadness", "Anxiety"], color: "red", category: "Emotions"),
    GroupJSON(theme: "Personality Traits", words: ["Brave", "Kind", "Wise", "Humble"], color: "green", category: "Emotions"),
    GroupJSON(theme: "Relationship Types", words: ["Friend", "Family", "Partner", "Colleague"], color: "pink", category: "Emotions"),

    // Business
    GroupJSON(theme: "Financial Terms", words: ["Stock", "Bond", "Equity", "Dividend"], color: "green", category: "Business"),
    GroupJSON(theme: "Marketing Concepts", words: ["Brand", "Target", "Campaign", "Launch"], color: "orange", category: "Business"),
    GroupJSON(theme: "Business Roles", words: ["CEO", "Manager", "Director", "Analyst"], color: "gray", category: "Business"),
    GroupJSON(theme: "Economic Terms", words: ["Inflation", "Recession", "GDP", "Deficit"], color: "red", category: "Business"),

    // Culture
    GroupJSON(theme: "World Cuisines", words: ["Italian", "Japanese", "Mexican", "Indian"], color: "orange", category: "Culture"),
    GroupJSON(theme: "Coffee Types", words: ["Espresso", "Latte", "Cappuccino", "Mocha"], color: "brown", category: "Culture"),
    GroupJSON(theme: "Wine Varieties", words: ["Merlot", "Cabernet", "Chardonnay", "Pinot"], color: "red", category: "Culture"),
    GroupJSON(theme: "Pasta Shapes", words: ["Penne", "Fusilli", "Spaghetti", "Ravioli"], color: "yellow", category: "Culture"),
    GroupJSON(theme: "World Languages", words: ["Spanish", "Mandarin", "French", "Arabic"], color: "blue", category: "Culture"),
    GroupJSON(theme: "Traditional Dances", words: ["Flamenco", "Hula", "Samba", "Waltz"], color: "pink", category: "Culture"),

    // Mixed/General
    GroupJSON(theme: "Colors", words: ["Red", "Blue", "Green", "Yellow"], color: "purple", category: "Arts"),
    GroupJSON(theme: "Seasons", words: ["Spring", "Summer", "Autumn", "Winter"], color: "teal", category: "Nature"),
    GroupJSON(theme: "Directions", words: ["North", "South", "East", "West"], color: "gray", category: "Science"),
    GroupJSON(theme: "Time Periods", words: ["Morning", "Afternoon", "Evening", "Night"], color: "indigo", category: "Culture"),
    GroupJSON(theme: "Basic Shapes", words: ["Circle", "Square", "Triangle", "Rectangle"], color: "blue", category: "Science"),
    GroupJSON(theme: "Days of Week", words: ["Monday", "Tuesday", "Wednesday", "Thursday"], color: "cyan", category: "Culture"),
    GroupJSON(theme: "Months", words: ["January", "February", "March", "April"], color: "green", category: "Culture"),
    GroupJSON(theme: "Numbers", words: ["One", "Two", "Three", "Four"], color: "purple", category: "Science"),
  ]
}
