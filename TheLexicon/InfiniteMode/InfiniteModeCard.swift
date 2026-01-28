//
//  InfiniteModeCard.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

struct InfiniteModeCard: View {
  let screenSize: CGSize
  let currentLevel: Int
  let completedLevels: Int
  let action: () -> Void

  private var levelData: InfiniteLevelData {
    InfiniteModeData.level(currentLevel)
  }

  private var difficulty: InfiniteModeDifficulty {
    levelData.difficulty
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: AppLayout.Spacing.md(screenSize)) {
        // Left: Level info
        VStack(alignment: .leading, spacing: AppLayout.Spacing.xxs(screenSize)) {
          Text("Infinite Mode")
            .font(AppFonts.body(screenSize))
            .fontWeight(.bold)
            .fontDesign(.serif)
            .foregroundStyle(AppColors.textPrimary)

          Text("Level \(currentLevel)")
            .font(AppFonts.title2(screenSize))
            .fontWeight(.black)
            .foregroundStyle(AppColors.accent)
        }

        Spacer()

        // Right: Difficulty badge and chevron
        HStack(spacing: AppLayout.Spacing.sm(screenSize)) {
          DifficultyBadge(
            difficulty: difficulty,
            screenSize: screenSize
          )

          Image(systemName: "chevron.right")
            .font(AppFonts.body(screenSize))
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.textMuted)
        }
      }
      .padding(AppLayout.Padding.md(screenSize))
      .frame(maxWidth: .infinity)
      .background {
        RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium(screenSize))
          .fill(AppColors.surfaceDefault)
      }
      .overlay {
        RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium(screenSize))
          .stroke(AppColors.borderMuted, lineWidth: AppLayout.Stroke.thin(screenSize))
      }
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Difficulty Badge

struct DifficultyBadge: View {
  let difficulty: InfiniteModeDifficulty
  let screenSize: CGSize

  var body: some View {
    HStack(spacing: AppLayout.Spacing.xxs(screenSize)) {
      Image(systemName: difficulty.icon)
        .font(.caption)

      Text(difficulty.rawValue)
        .font(AppFonts.caption(screenSize))
        .fontWeight(.semibold)
    }
    .foregroundStyle(difficulty.color)
    .padding(.horizontal, AppLayout.Padding.sm(screenSize))
    .padding(.vertical, AppLayout.Spacing.xxs(screenSize))
    .background {
      Capsule()
        .fill(difficulty.color.opacity(0.15))
    }
  }
}

// MARK: - Preview

#Preview {
  GeometryReader { geometry in
    ScrollView {
      VStack(spacing: 16) {
        InfiniteModeCard(
          screenSize: geometry.size,
          currentLevel: 1,
          completedLevels: 0
        ) {
          print("Tapped level 1")
        }

        InfiniteModeCard(
          screenSize: geometry.size,
          currentLevel: 3,
          completedLevels: 2
        ) {
          print("Tapped level 3")
        }

        InfiniteModeCard(
          screenSize: geometry.size,
          currentLevel: 6,
          completedLevels: 5
        ) {
          print("Tapped level 6")
        }

        InfiniteModeCard(
          screenSize: geometry.size,
          currentLevel: 9,
          completedLevels: 8
        ) {
          print("Tapped level 9")
        }
      }
      .padding()
    }
  }
}
