//
//  LevelData.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

// MARK: - JSON Codable Models

struct LevelFileData: Codable {
  let levels: [LevelJSON]
}

struct LevelJSON: Codable {
  let id: Int
  let groups: [GroupJSON]
  let difficulty: String
}

struct GroupJSON: Codable {
  let theme: String
  let words: [String]
  let color: String
  let category: String
}

// MARK: - Word Definition

struct WordDefinition: Codable, Identifiable {
  let id: String // lowercase word as identifier
  let word: String
  let definition: String
  let difficulty: Int // 1-10
  let category: String // Maps to SemanticCategory
  let pronunciation: String?
  let example: String?

  init(
    word: String,
    definition: String,
    difficulty: Int,
    category: String,
    pronunciation: String? = nil,
    example: String? = nil
  ) {
    self.id = word.lowercased()
    self.word = word
    self.definition = definition
    self.difficulty = difficulty
    self.category = category
    self.pronunciation = pronunciation
    self.example = example
  }
}

struct WordDefinitionsFile: Codable {
  let words: [WordDefinition]
}

// MARK: - Color Mapping

extension GroupJSON {
  var swiftUIColor: Color {
    switch color.lowercased() {
    case "blue": return .blue
    case "green": return .green
    case "orange": return .orange
    case "purple": return .purple
    case "red": return .red
    case "cyan": return .cyan
    case "pink": return .pink
    case "brown": return .brown
    case "indigo": return .indigo
    case "gray", "grey": return .gray
    case "teal": return .teal
    case "mint": return .mint
    case "yellow": return .yellow
    default: return .blue
    }
  }

  func toWordGroup() -> WordGroup {
    WordGroup(
      theme: theme,
      words: words,
      color: swiftUIColor
    )
  }
}

// MARK: - Difficulty Mapping

extension LevelJSON {
  var infiniteDifficulty: InfiniteModeDifficulty {
    switch difficulty.lowercased() {
    case "easy": return .easy
    case "medium": return .medium
    case "hard": return .hard
    case "expert": return .expert
    default: return .easy
    }
  }

  func toInfiniteLevelData() -> InfiniteLevelData {
    InfiniteLevelData(
      groups: groups.map { $0.toWordGroup() },
      difficulty: infiniteDifficulty
    )
  }
}
