//
//  ConnectionsGameData.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

// MARK: - Game Data Provider

struct ConnectionsGameData {

  /// Returns the game configuration for a specific date
  /// Daily games are derived from the infinite level pool based on date
  static func game(for date: Date) -> [WordGroup] {
    LevelDatabase.shared.groups(for: date)
  }

  /// Returns the level number for a specific date (for display purposes)
  static func levelNumber(for date: Date) -> Int {
    LevelDatabase.shared.levelNumber(for: date)
  }

  /// Returns the difficulty for a specific date
  static func difficulty(for date: Date) -> InfiniteModeDifficulty {
    let levelNumber = LevelDatabase.shared.levelNumber(for: date)
    return LevelDatabase.shared.difficulty(for: levelNumber)
  }
}
