//
//  InfiniteModeData.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

// MARK: - Difficulty

enum InfiniteModeDifficulty: String, CaseIterable {
  case easy = "Easy"
  case medium = "Medium"
  case hard = "Hard"
  case expert = "Expert"

  var color: Color {
    switch self {
    case .easy: return .green
    case .medium: return .orange
    case .hard: return .red
    case .expert: return .purple
    }
  }

  var icon: String {
    switch self {
    case .easy: return "leaf"
    case .medium: return "flame"
    case .hard: return "bolt.fill"
    case .expert: return "crown.fill"
    }
  }
}

// MARK: - Level Data

struct InfiniteLevelData {
  let groups: [WordGroup]
  let difficulty: InfiniteModeDifficulty

  var wordCount: Int { groups.count * 4 }
  var groupCount: Int { groups.count }
}

// MARK: - Game Data Provider (deprecated - use LevelDatabase directly)

// NOTE: This struct is kept for backwards compatibility but is deprecated.
// Use LevelDatabase directly for level() and difficulty() functions.
// InfiniteModeData.totalLevels is equivalent to LevelDatabase.totalLevels
