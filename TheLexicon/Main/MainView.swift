//
//  MainView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 26/01/2026.
//

import SwiftUI

struct MainView: View {

  let dependencies: AppDependencies

  @Environment(\.scenePhase) private var scenePhase

  @State private var showGame: Bool = false
  @State private var showInfiniteGame: Bool = false
  @State private var showStreakView: Bool = false
  @State private var showVocabularyTest: Bool = false
  @State private var showProfileDetail: Bool = false
  @State private var showWordRevision: Bool = false
  @State private var showDebugMenu: Bool = false
  @State private var settingsTapCount: Int = 0
  @State private var lastSettingsTapTime: Date = Date()
  @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
  @State private var lastActiveDate: Date = Calendar.current.startOfDay(for: Date())

  private var streakCount: Int {
    dependencies.streakManager.currentStreak
  }

  private var vocabularyProfile: VocabularyProfileManager {
    dependencies.vocabularyProfileManager
  }

  private var wordOfTheDay: WordDefinition? {
    dependencies.wordDatabase.wordOfTheDay(for: Date())
  }


  private var selectedProgress: DailyProgress {
    dependencies.dailyProgressManager.progress(for: selectedDate)
  }

  private var selectedGameData: [WordGroup] {
    dependencies.levelDatabase.groups(for: selectedDate)
  }

  private var wordCount: Int {
    selectedGameData.count * 4
  }

  private var groupCount: Int {
    selectedGameData.count
  }

  private var difficulty: String {
    switch selectedGameData.count {
    case 1...4: return "Easy"
    case 5...6: return "Medium"
    case 7...8: return "Hard"
    default: return "Expert"
    }
  }

  private var isSelectedDayCompleted: Bool {
    selectedProgress.completedGroups >= groupCount && groupCount > 0
  }

  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        VStack(spacing: 0) {
          ScrollView {
            VStack(spacing: AppLayout.Spacing.lg(geometry.size)) {
              HorizontalCalendar(
                screenSize: geometry.size,
                selectedDate: $selectedDate,
                dependencies: dependencies
              )

              ConnectionsGameCard(
                screenSize: geometry.size,
                wordCount: wordCount,
                groupCount: groupCount,
                completedGroups: selectedProgress.completedGroups,
                difficulty: difficulty
              )
              .padding(.horizontal, AppLayout.Padding.md(geometry.size))
              .animation(.easeInOut(duration: 0.2), value: selectedDate)

              // Infinite Mode Card
              InfiniteModeCard(
                screenSize: geometry.size,
                currentLevel: dependencies.infiniteModeProgressManager.currentLevel,
                completedLevels: dependencies.infiniteModeProgressManager.completedLevels,
                levelDatabase: dependencies.levelDatabase
              ) {
                showInfiniteGame = true
              }
              .padding(.horizontal, AppLayout.Padding.md(geometry.size))

              // Vocabulary Profile Card
              VocabularyProfileCard(
                screenSize: geometry.size,
                hasCompletedTest: vocabularyProfile.hasCompletedInitialTest,
                vocabularyLevel: vocabularyProfile.vocabularyLevel,
                overallScore: vocabularyProfile.overallScore,
                categoryScores: vocabularyProfile.normalizedCategoryScores
              ) {
                if vocabularyProfile.hasCompletedInitialTest {
                  showProfileDetail = true
                } else {
                  showVocabularyTest = true
                }
              }
              .padding(.horizontal, AppLayout.Padding.md(geometry.size))

              // Word of the Day Card
              WordOfTheDayCard(
                screenSize: geometry.size,
                word: wordOfTheDay
              ) {
                showWordRevision = true
              }
              .padding(.horizontal, AppLayout.Padding.md(geometry.size))

              // Word Revision Card
              WordRevisionCard(
                screenSize: geometry.size,
                dependencies: dependencies
              ) {
                showWordRevision = true
              }
              .padding(.horizontal, AppLayout.Padding.md(geometry.size))
            }
          }

          SessionStartButton(isCompleted: isSelectedDayCompleted) {
            showGame = true
          }
        }
      }
      .fullScreenCover(isPresented: $showGame) {
        ConnectionsGameView(dependencies: dependencies, date: selectedDate)
      }
      .fullScreenCover(isPresented: $showInfiniteGame) {
        ConnectionsGameView(dependencies: dependencies, infiniteLevel: dependencies.infiniteModeProgressManager.currentLevel)
      }
      .fullScreenCover(isPresented: $showStreakView) {
        StreakCelebrationView(
          streakCount: streakCount,
          longestStreak: dependencies.streakManager.longestStreak,
          isNewStreak: false
        )
      }
      .fullScreenCover(isPresented: $showVocabularyTest) {
        VocabularyTestView(dependencies: dependencies)
      }
      .fullScreenCover(isPresented: $showProfileDetail) {
        ProfileDetailView(
          vocabularyLevel: vocabularyProfile.vocabularyLevel,
          overallScore: vocabularyProfile.overallScore,
          totalWordsLearned: vocabularyProfile.totalWordsLearned,
          categoryScores: vocabularyProfile.normalizedCategoryScores
        )
      }
      .fullScreenCover(isPresented: $showWordRevision) {
        WordRevisionView(dependencies: dependencies)
      }
      .fullScreenCover(isPresented: $showDebugMenu) {
        DebugMenuView(dependencies: dependencies)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            showStreakView = true
          } label: {
            StreakBadge(count: streakCount)
          }
          .buttonStyle(.plain)
        }

        ToolbarItem(placement: .principal) {
          Text("The Lexicon")
            .fontWeight(.black)
            .font(.custom("NewYork-Bold", size: 25))
            .fontDesign(.serif)
            .foregroundStyle(AppColors.accentMuted)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            handleSettingsTap()
          } label: {
            Image(systemName: "gearshape")
          }
        }
      }
      .onChange(of: scenePhase) { _, newPhase in
        if newPhase == .active {
          checkForDayChange()
        }
      }
    }
  }

  // MARK: - Settings Tap (Debug Menu Activation)

  private func handleSettingsTap() {
    let now = Date()
    // Reset count if more than 2 seconds since last tap
    if now.timeIntervalSince(lastSettingsTapTime) > 2.0 {
      settingsTapCount = 0
    }

    lastSettingsTapTime = now
    settingsTapCount += 1

    if settingsTapCount >= 5 {
      settingsTapCount = 0
      showDebugMenu = true
    }
  }

  // MARK: - Day Change Detection

  private func checkForDayChange() {
    let today = Calendar.current.startOfDay(for: Date())

    // If the day has changed since we last checked
    if today != lastActiveDate {
      lastActiveDate = today

      // If user was viewing the previous "today", update to new today
      if selectedDate == Calendar.current.date(byAdding: .day, value: -1, to: today) {
        selectedDate = today
      }
    }
  }
}

struct StreakBadge: View {
  let count: Int

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "flame.fill")
        .foregroundStyle(AppColors.accent)
      Text("\(count)")
        .fontWeight(.semibold)
        .contentTransition(.numericText())
    }
    .font(.subheadline)
  }
}

#Preview {
  MainView(dependencies: .forPreview())
}
