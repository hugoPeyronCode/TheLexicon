//
//  ConnectionsGameCard.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

struct ConnectionsGameCard: View {
  let screenSize: CGSize
  let wordCount: Int
  let groupCount: Int
  let completedGroups: Int
  let difficulty: String

  private var isCompleted: Bool {
    completedGroups >= groupCount && groupCount > 0
  }

  private var progress: CGFloat {
    guard groupCount > 0 else { return 0 }
    return CGFloat(completedGroups) / CGFloat(groupCount)
  }

  var body: some View {
    VStack(spacing: AppLayout.Spacing.lg(screenSize)) {

      // Header
      HStack {
        VStack(alignment: .leading, spacing: AppLayout.Spacing.xxs(screenSize)) {
          Text("Connections")
            .font(AppFonts.title2(screenSize))
            .fontWeight(.bold)
            .fontDesign(.serif)
            .foregroundStyle(AppColors.textPrimary)

          Text("Find the hidden word families")
            .font(AppFonts.caption(screenSize))
            .foregroundStyle(AppColors.textSecondary)
        }

        Spacer()

        if isCompleted {
          HStack(spacing: AppLayout.Spacing.xxs(screenSize)) {
            Image(systemName: "checkmark.circle.fill")
            Text("Completed")
          }
          .font(AppFonts.caption(screenSize))
          .fontWeight(.medium)
          .foregroundStyle(AppColors.stateSuccess)
        } else {
          Text(difficulty)
            .font(AppFonts.caption(screenSize))
            .fontWeight(.medium)
            .foregroundStyle(AppColors.accent)
            .padding(.horizontal, AppLayout.Padding.sm(screenSize))
            .padding(.vertical, AppLayout.Spacing.xxs(screenSize))
            .background {
              Capsule()
                .fill(AppColors.accentSubtle)
            }
        }
      }

      // Central Progress Ring
      ZStack {
        Circle()
          .stroke(AppColors.surfaceDisabled, lineWidth: 8)

        Circle()
          .trim(from: 0, to: progress)
          .stroke(
            isCompleted ? AppColors.stateSuccess : AppColors.accent,
            style: StrokeStyle(lineWidth: 8, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
          .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)

        VStack(spacing: AppLayout.Spacing.xxs(screenSize)) {
          if isCompleted {
            Image(systemName: "checkmark")
              .font(.system(size: screenSize.width * 0.08))
              .fontWeight(.bold)
              .foregroundStyle(AppColors.stateSuccess)
          } else {
            Text("\(completedGroups)/\(groupCount)")
              .font(AppFonts.title(screenSize))
              .fontWeight(.bold)
              .foregroundStyle(AppColors.textPrimary)
              .contentTransition(.numericText())

            Text("groups")
              .font(AppFonts.caption(screenSize))
              .foregroundStyle(AppColors.textMuted)
          }
        }
      }
      .frame(width: screenSize.width * 0.35, height: screenSize.width * 0.35)

      // Stats Row
      HStack(spacing: 0) {
        StatItem(
          screenSize: screenSize,
          icon: "textformat.abc",
          value: "\(wordCount)",
          label: "Words"
        )

        Divider()
          .frame(height: screenSize.width * 0.08)

        StatItem(
          screenSize: screenSize,
          icon: "square.grid.2x2",
          value: "\(groupCount)",
          label: "Families"
        )

        Divider()
          .frame(height: screenSize.width * 0.08)

        StatItem(
          screenSize: screenSize,
          icon: "percent",
          value: "\(Int(progress * 100))%",
          label: "Progress"
        )
      }
    }
    .padding(AppLayout.Padding.lg(screenSize))
    .frame(maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: AppLayout.CornerRadius.large(screenSize))
        .fill(isCompleted ? AppColors.stateSuccessSubtle : AppColors.surfaceDefault)
    }
    .overlay {
      RoundedRectangle(cornerRadius: AppLayout.CornerRadius.large(screenSize))
        .stroke(
          isCompleted ? AppColors.stateSuccess.opacity(0.3) : AppColors.borderMuted,
          lineWidth: AppLayout.Stroke.thin(screenSize)
        )
    }
    .animation(.easeInOut(duration: 0.3), value: completedGroups)
  }
}

// MARK: - Stat Item

private struct StatItem: View {
  let screenSize: CGSize
  let icon: String
  let value: String
  let label: String

  var body: some View {
    VStack(spacing: AppLayout.Spacing.xxs(screenSize)) {
      Image(systemName: icon)
        .font(AppFonts.caption(screenSize))
        .foregroundStyle(AppColors.textMuted)

      Text(value)
        .font(AppFonts.body(screenSize))
        .fontWeight(.bold)
        .foregroundStyle(AppColors.textPrimary)
        .contentTransition(.numericText())

      Text(label)
        .font(AppFonts.caption2(screenSize))
        .foregroundStyle(AppColors.textMuted)
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Preview

#Preview {
  GeometryReader { geometry in
    ScrollView{
      ConnectionsGameCard(
        screenSize: geometry.size,
        wordCount: 16,
        groupCount: 4,
        completedGroups: 0,
        difficulty: "Easy"
      )
      .padding(.horizontal)

      ConnectionsGameCard(
        screenSize: geometry.size,
        wordCount: 32,
        groupCount: 8,
        completedGroups: 5,
        difficulty: "Medium"
      )
      .padding(.horizontal)

      ConnectionsGameCard(
        screenSize: geometry.size,
        wordCount: 16,
        groupCount: 4,
        completedGroups: 4,
        difficulty: "Easy"
      )
      .padding(.horizontal)

      Spacer()
    }
    .padding(.top, 50)
  }
}
