//
//  PreviewContainer.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Preview Container

struct PreviewContainer {
  let container: ModelContainer
  let context: ModelContext

  init() {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try! ModelContainer(
      for: DailyProgress.self,
      PuzzleState.self,
      InfiniteModeProgress.self,
      StreakData.self,
      VocabularyProfile.self,
      CategoryScore.self,
      configurations: config
    )
    context = ModelContext(container)

    // Configure the shared managers with preview context
    DailyProgressManager.shared.configure(with: context)
    PuzzleStateManager.shared.configure(with: context)
    InfiniteModeProgressManager.shared.configure(with: context)
    StreakManager.shared.configure(with: context)
    VocabularyProfileManager.shared.configure(with: context)

    // Add sample data
    addSampleData()
  }

  private func addSampleData() {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    // Yesterday - completed
    if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
      let progress = DailyProgress(date: yesterday, completedGroups: 4, totalGroups: 4)
      context.insert(progress)
    }

    // Two days ago - partial
    if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) {
      let progress = DailyProgress(date: twoDaysAgo, completedGroups: 2, totalGroups: 4)
      context.insert(progress)
    }

    // Three days ago - completed
    if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today) {
      let progress = DailyProgress(date: threeDaysAgo, completedGroups: 4, totalGroups: 4)
      context.insert(progress)
    }

    // Today - in progress
    let todayProgress = DailyProgress(date: today, completedGroups: 1, totalGroups: 4)
    context.insert(todayProgress)

    try? context.save()

    // Reload the manager cache
    DailyProgressManager.shared.configure(with: context)
  }
}

// MARK: - Preview Modifier

struct WithPreviewContainer: ViewModifier {
  let previewContainer: PreviewContainer

  init() {
    previewContainer = PreviewContainer()
  }

  func body(content: Content) -> some View {
    content
      .modelContainer(previewContainer.container)
  }
}

extension View {
  func withPreviewContainer() -> some View {
    modifier(WithPreviewContainer())
  }
}
