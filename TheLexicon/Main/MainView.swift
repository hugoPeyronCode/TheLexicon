//
//  MainView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 26/01/2026.
//

import SwiftUI

struct MainView: View {

  @State private var streakCount: Int = 7
  @State private var showGame: Bool = false
  @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

  private var selectedProgress: DailyProgress {
    DailyProgressManager.shared.progress(for: selectedDate)
  }

  private var selectedGameData: [WordGroup] {
    ConnectionsGameData.game(for: selectedDate)
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
              HorizontalCalendar(screenSize: geometry.size, selectedDate: $selectedDate)

              ConnectionsGameCard(
                screenSize: geometry.size,
                wordCount: wordCount,
                groupCount: groupCount,
                completedGroups: selectedProgress.completedGroups,
                difficulty: difficulty
              )
              .padding(.horizontal, AppLayout.Padding.md(geometry.size))
              .animation(.easeInOut(duration: 0.2), value: selectedDate)
            }
          }

          SessionStartButton(isCompleted: isSelectedDayCompleted) {
            showGame = true
          }
        }
      }
      .fullScreenCover(isPresented: $showGame) {
        ConnectionsGameView(date: selectedDate)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          StreakBadge(count: streakCount)
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
            // Settings action
          } label: {
            Image(systemName: "gearshape")
          }
        }
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
    }
    .font(.subheadline)
  }
}

#Preview {
  MainView()
    .withPreviewContainer()
}
