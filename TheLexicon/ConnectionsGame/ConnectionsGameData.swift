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
  /// Each day has a unique puzzle with varying sizes
  static func game(for date: Date) -> [WordGroup] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let targetDate = calendar.startOfDay(for: date)

    let daysDifference = calendar.dateComponents([.day], from: targetDate, to: today).day ?? 0

    // Return game based on days ago (0 = today, 1 = yesterday, etc.)
    // Different sizes: 4 rows (16 words), 6 rows (24 words), 8 rows (32 words), etc.
    switch daysDifference {
    case 0:
      return todayGame       // 4 rows - Standard
    case 1:
      return day1Game        // 6 rows - Medium
    case 2:
      return day2Game        // 8 rows - Large
    case 3:
      return day3Game        // 4 rows - Standard
    case 4:
      return day4Game        // 10 rows - Extra Large
    case 5:
      return day5Game        // 6 rows - Medium
    default:
      return defaultGame
    }
  }

  // MARK: - Today's Game (4 rows - 16 words)

  static let todayGame: [WordGroup] = [
    WordGroup(
      theme: "Colors",
      words: ["Red", "Blue", "Green", "Yellow"],
      color: .blue
    ),
    WordGroup(
      theme: "Fruits",
      words: ["Apple", "Banana", "Orange", "Grape"],
      color: .green
    ),
    WordGroup(
      theme: "Animals",
      words: ["Dog", "Cat", "Bird", "Fish"],
      color: .orange
    ),
    WordGroup(
      theme: "Numbers",
      words: ["One", "Two", "Three", "Four"],
      color: .purple
    )
  ]

  // MARK: - Yesterday's Game (6 rows - 24 words)

  static let day1Game: [WordGroup] = [
    WordGroup(
      theme: "Weather",
      words: ["Rain", "Snow", "Wind", "Sun"],
      color: .cyan
    ),
    WordGroup(
      theme: "Clothing",
      words: ["Shirt", "Pants", "Shoes", "Hat"],
      color: .pink
    ),
    WordGroup(
      theme: "Furniture",
      words: ["Chair", "Table", "Bed", "Desk"],
      color: .brown
    ),
    WordGroup(
      theme: "Vehicles",
      words: ["Car", "Bus", "Bike", "Boat"],
      color: .indigo
    ),
    WordGroup(
      theme: "Planets",
      words: ["Mars", "Venus", "Earth", "Saturn"],
      color: .red
    ),
    WordGroup(
      theme: "Metals",
      words: ["Gold", "Silver", "Iron", "Copper"],
      color: .gray
    )
  ]

  // MARK: - Day 2 Game (8 rows - 32 words)

  static let day2Game: [WordGroup] = [
    WordGroup(
      theme: "Body Parts",
      words: ["Hand", "Foot", "Head", "Arm"],
      color: .red
    ),
    WordGroup(
      theme: "Food",
      words: ["Bread", "Rice", "Meat", "Soup"],
      color: .orange
    ),
    WordGroup(
      theme: "Sports",
      words: ["Tennis", "Soccer", "Golf", "Rugby"],
      color: .green
    ),
    WordGroup(
      theme: "Music",
      words: ["Piano", "Guitar", "Drums", "Violin"],
      color: .purple
    ),
    WordGroup(
      theme: "Countries",
      words: ["France", "Japan", "Brazil", "Egypt"],
      color: .blue
    ),
    WordGroup(
      theme: "Trees",
      words: ["Oak", "Pine", "Maple", "Birch"],
      color: .mint
    ),
    WordGroup(
      theme: "Gems",
      words: ["Ruby", "Diamond", "Pearl", "Emerald"],
      color: .pink
    ),
    WordGroup(
      theme: "Insects",
      words: ["Bee", "Ant", "Fly", "Moth"],
      color: .yellow
    )
  ]

  // MARK: - Day 3 Game (4 rows - 16 words)

  static let day3Game: [WordGroup] = [
    WordGroup(
      theme: "Seasons",
      words: ["Spring", "Summer", "Fall", "Winter"],
      color: .teal
    ),
    WordGroup(
      theme: "Drinks",
      words: ["Water", "Juice", "Milk", "Tea"],
      color: .blue
    ),
    WordGroup(
      theme: "Rooms",
      words: ["Kitchen", "Bedroom", "Bathroom", "Garden"],
      color: .mint
    ),
    WordGroup(
      theme: "Shapes",
      words: ["Circle", "Square", "Triangle", "Star"],
      color: .yellow
    )
  ]

  // MARK: - Day 4 Game (10 rows - 40 words)

  static let day4Game: [WordGroup] = [
    WordGroup(
      theme: "Family",
      words: ["Mother", "Father", "Sister", "Brother"],
      color: .pink
    ),
    WordGroup(
      theme: "Tools",
      words: ["Hammer", "Saw", "Drill", "Wrench"],
      color: .gray
    ),
    WordGroup(
      theme: "Emotions",
      words: ["Happy", "Sad", "Angry", "Scared"],
      color: .red
    ),
    WordGroup(
      theme: "Time",
      words: ["Morning", "Noon", "Evening", "Night"],
      color: .indigo
    ),
    WordGroup(
      theme: "Ocean Life",
      words: ["Shark", "Whale", "Dolphin", "Octopus"],
      color: .blue
    ),
    WordGroup(
      theme: "Desserts",
      words: ["Cake", "Pie", "Cookie", "Donut"],
      color: .brown
    ),
    WordGroup(
      theme: "Directions",
      words: ["North", "South", "East", "West"],
      color: .teal
    ),
    WordGroup(
      theme: "Flowers",
      words: ["Rose", "Tulip", "Daisy", "Lily"],
      color: .purple
    ),
    WordGroup(
      theme: "Birds",
      words: ["Eagle", "Owl", "Hawk", "Crow"],
      color: .orange
    ),
    WordGroup(
      theme: "Languages",
      words: ["English", "Spanish", "French", "German"],
      color: .cyan
    )
  ]

  // MARK: - Day 5 Game (6 rows - 24 words)

  static let day5Game: [WordGroup] = [
    WordGroup(
      theme: "Nature",
      words: ["Tree", "Flower", "Grass", "River"],
      color: .green
    ),
    WordGroup(
      theme: "Jobs",
      words: ["Doctor", "Teacher", "Chef", "Artist"],
      color: .blue
    ),
    WordGroup(
      theme: "Materials",
      words: ["Wood", "Metal", "Glass", "Paper"],
      color: .brown
    ),
    WordGroup(
      theme: "Actions",
      words: ["Run", "Jump", "Swim", "Dance"],
      color: .orange
    ),
    WordGroup(
      theme: "Spices",
      words: ["Salt", "Pepper", "Basil", "Thyme"],
      color: .red
    ),
    WordGroup(
      theme: "Planets",
      words: ["Jupiter", "Neptune", "Mercury", "Uranus"],
      color: .indigo
    )
  ]

  // MARK: - Default Game (for dates outside range)

  static let defaultGame: [WordGroup] = todayGame
}
