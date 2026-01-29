//
//  DebugMenuView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

struct DebugMenuView: View {
  @Environment(\.dismiss) private var dismiss

  let dependencies: AppDependencies

  @State private var selectedTab: DebugTab = .daily
  @State private var selectedLevel: Int = 1
  @State private var showGame: Bool = false

  enum DebugTab: String, CaseIterable {
    case daily = "Daily"
    case infinite = "Infinite"
    case data = "Data"
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // Tab selector
        Picker("Mode", selection: $selectedTab) {
          ForEach(DebugTab.allCases, id: \.self) { tab in
            Text(tab.rawValue).tag(tab)
          }
        }
        .pickerStyle(.segmented)
        .padding()

        // Content
        switch selectedTab {
        case .daily:
          dailyLevelsList
        case .infinite:
          infiniteLevelsList
        case .data:
          dataInfoView
        }
      }
      .background(AppColors.backgroundPrimary)
      .navigationTitle("Debug Menu")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Close") {
            dismiss()
          }
        }
      }
      .fullScreenCover(isPresented: $showGame) {
        if selectedTab == .daily {
          ConnectionsGameView(dependencies: dependencies, date: dateForLevel(selectedLevel))
        } else {
          ConnectionsGameView(dependencies: dependencies, infiniteLevel: selectedLevel)
        }
      }
    }
  }

  // MARK: - Daily Levels List

  private var dailyLevelsList: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        ForEach(1...30, id: \.self) { daysAgo in
          let date = Calendar.current.date(byAdding: .day, value: -daysAgo + 1, to: Date()) ?? Date()
          let levelNumber = dependencies.levelDatabase.levelNumber(for: date)
          let difficulty = dependencies.levelDatabase.difficulty(for: levelNumber)
          let groups = dependencies.levelDatabase.groups(for: date)

          DebugLevelRow(
            title: "Day \(daysAgo): Level \(levelNumber)",
            subtitle: formatDate(date),
            difficulty: difficulty,
            groupCount: groups.count
          ) {
            selectedLevel = daysAgo
            showGame = true
          }
        }
      }
      .padding()
    }
  }

  // MARK: - Infinite Levels List

  private var infiniteLevelsList: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        // Quick jump section
        quickJumpSection

        Divider()
          .padding(.vertical)

        // Level list
        ForEach(1...50, id: \.self) { level in
          let levelData = dependencies.levelDatabase.level(level)

          DebugLevelRow(
            title: "Level \(level)",
            subtitle: "\(levelData.groups.count) groups • \(levelData.wordCount) words",
            difficulty: levelData.difficulty,
            groupCount: levelData.groups.count
          ) {
            selectedLevel = level
            selectedTab = .infinite
            showGame = true
          }
        }

        // Load more indicator
        Text("Showing 1-50 of 500 levels")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)
          .padding()
      }
      .padding()
    }
  }

  private var quickJumpSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Quick Jump")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 8) {
        ForEach([1, 10, 50, 100, 200, 300, 400, 500], id: \.self) { level in
          Button {
            selectedLevel = level
            selectedTab = .infinite
            showGame = true
          } label: {
            Text("\(level)")
              .font(.caption)
              .fontWeight(.medium)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
              .background {
                RoundedRectangle(cornerRadius: 8)
                  .fill(AppColors.surfaceDefault)
              }
              .overlay {
                RoundedRectangle(cornerRadius: 8)
                  .stroke(AppColors.borderMuted, lineWidth: 1)
              }
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  // MARK: - Data Info View

  private var dataInfoView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Level Database Info
        infoSection(title: "Level Database") {
          infoRow("Total Levels", "\(LevelDatabase.totalLevels)")
          infoRow("Reference Date", "Jan 1, 2026")
        }

        // Word Database Info
        infoSection(title: "Word Database") {
          infoRow("Total Words", "\(dependencies.wordDatabase.all.count)")
          infoRow("Harder Words (5+)", "\(dependencies.wordDatabase.harderWords.count)")
        }

        // Category Distribution
        infoSection(title: "Words by Category") {
          ForEach(SemanticCategory.allCases, id: \.self) { category in
            let count = dependencies.wordDatabase.words(for: category).count
            infoRow(category.rawValue, "\(count)")
          }
        }

        // Vocabulary Profile Info
        infoSection(title: "Vocabulary Profile") {
          infoRow("Has Completed Test", "\(dependencies.vocabularyProfileManager.hasCompletedInitialTest)")
          infoRow("Overall Score", "\(dependencies.vocabularyProfileManager.overallScore)")
          infoRow("Level", "\(dependencies.vocabularyProfileManager.vocabularyLevel)")
          infoRow("Words Learned", "\(dependencies.vocabularyProfileManager.totalWordsLearned)")
        }

        // Streak Info
        infoSection(title: "Streak Data") {
          infoRow("Current Streak", "\(dependencies.streakManager.currentStreak)")
          infoRow("Longest Streak", "\(dependencies.streakManager.longestStreak)")
        }

        // Infinite Mode Progress
        infoSection(title: "Infinite Mode") {
          infoRow("Current Level", "\(dependencies.infiniteModeProgressManager.currentLevel)")
          infoRow("Completed Levels", "\(dependencies.infiniteModeProgressManager.completedLevels)")
        }

        // Reset buttons
        VStack(spacing: 12) {
          Text("Danger Zone")
            .font(.headline)
            .foregroundStyle(.red)

          Button(role: .destructive) {
            // Reset infinite mode progress
            // This would need a reset method in the manager
          } label: {
            Text("Reset Infinite Mode Progress")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
          .disabled(true) // Enable when reset method is added
        }
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.red.opacity(0.1))
        }
      }
      .padding()
    }
  }

  @ViewBuilder
  private func infoSection(title: String, @ViewBuilder content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      VStack(spacing: 4) {
        content()
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background {
        RoundedRectangle(cornerRadius: 12)
          .fill(AppColors.surfaceDefault)
      }
    }
  }

  @ViewBuilder
  private func infoRow(_ label: String, _ value: String) -> some View {
    HStack {
      Text(label)
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
      Spacer()
      Text(value)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(AppColors.textPrimary)
    }
  }

  // MARK: - Helpers

  private func dateForLevel(_ daysAgo: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: -daysAgo + 1, to: Date()) ?? Date()
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
  }
}

// MARK: - Debug Level Row

private struct DebugLevelRow: View {
  let title: String
  let subtitle: String
  let difficulty: InfiniteModeDifficulty
  let groupCount: Int
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)

          Text(subtitle)
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }

        Spacer()

        // Difficulty badge
        HStack(spacing: 4) {
          Image(systemName: difficulty.icon)
            .font(.caption)
          Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.medium)
        }
        .foregroundStyle(difficulty.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
          Capsule()
            .fill(difficulty.color.opacity(0.15))
        }

        Image(systemName: "play.fill")
          .font(.caption)
          .foregroundStyle(AppColors.accent)
      }
      .padding()
      .background {
        RoundedRectangle(cornerRadius: 12)
          .fill(AppColors.surfaceDefault)
      }
      .overlay {
        RoundedRectangle(cornerRadius: 12)
          .stroke(AppColors.borderMuted, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Preview

#Preview {
  DebugMenuView(dependencies: .forPreview())
}
