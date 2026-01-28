//
//  VocabularyProfileCard.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

struct VocabularyProfileCard: View {
  let screenSize: CGSize
  let hasCompletedTest: Bool
  let vocabularyLevel: Int
  let overallScore: Int
  let categoryScores: [SemanticCategory: CGFloat]
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      if hasCompletedTest {
        completedTestContent
      } else {
        takeTestContent
      }
    }
    .buttonStyle(.plain)
  }

  // MARK: - Completed Test View

  private var completedTestContent: some View {
    HStack(spacing: AppLayout.Spacing.md(screenSize)) {
      // Left: Mini spider graph
      MiniSpiderGraphView(
        scores: categoryScores,
        size: 70
      )

      // Middle: Stats
      VStack(alignment: .leading, spacing: AppLayout.Spacing.xxs(screenSize)) {
        Text("Your Lexicon")
          .font(AppFonts.body(screenSize))
          .fontWeight(.bold)
          .fontDesign(.serif)
          .foregroundStyle(AppColors.textPrimary)

        HStack(spacing: AppLayout.Spacing.sm(screenSize)) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Level")
              .font(AppFonts.caption(screenSize))
              .foregroundStyle(AppColors.textSecondary)
            Text("\(vocabularyLevel)")
              .font(AppFonts.title2(screenSize))
              .fontWeight(.black)
              .foregroundStyle(AppColors.accent)
          }

          VStack(alignment: .leading, spacing: 2) {
            Text("Score")
              .font(AppFonts.caption(screenSize))
              .foregroundStyle(AppColors.textSecondary)
            Text("\(overallScore)")
              .font(AppFonts.title3(screenSize))
              .fontWeight(.bold)
              .foregroundStyle(AppColors.textPrimary)
          }
        }
      }

      Spacer()

      // Right: Chevron
      Image(systemName: "chevron.right")
        .font(AppFonts.body(screenSize))
        .fontWeight(.semibold)
        .foregroundStyle(AppColors.textMuted)
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

  // MARK: - Take Test View

  private var takeTestContent: some View {
    HStack(spacing: AppLayout.Spacing.md(screenSize)) {
      // Left: Icon
      ZStack {
        Circle()
          .fill(AppColors.accentSubtle)
          .frame(width: 60, height: 60)

        Image(systemName: "brain.head.profile")
          .font(.title2)
          .foregroundStyle(AppColors.accent)
      }

      // Middle: Text
      VStack(alignment: .leading, spacing: AppLayout.Spacing.xxs(screenSize)) {
        Text("Discover Your Lexicon")
          .font(AppFonts.body(screenSize))
          .fontWeight(.bold)
          .fontDesign(.serif)
          .foregroundStyle(AppColors.textPrimary)

        Text("Take a quick test to measure your vocabulary")
          .font(AppFonts.caption(screenSize))
          .foregroundStyle(AppColors.textSecondary)
          .lineLimit(2)
      }

      Spacer()

      // Right: CTA
      Text("Start")
        .font(AppFonts.caption(screenSize))
        .fontWeight(.bold)
        .foregroundStyle(.white)
        .padding(.horizontal, AppLayout.Padding.sm(screenSize))
        .padding(.vertical, AppLayout.Spacing.xs(screenSize))
        .background {
          Capsule()
            .fill(AppColors.accent)
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
        .stroke(AppColors.accent.opacity(0.3), lineWidth: AppLayout.Stroke.thin(screenSize))
    }
  }
}

// MARK: - Preview

#Preview("Completed Test") {
  GeometryReader { geometry in
    VStack {
      VocabularyProfileCard(
        screenSize: geometry.size,
        hasCompletedTest: true,
        vocabularyLevel: 42,
        overallScore: 1250,
        categoryScores: [
          .technology: 0.45,
          .arts: 0.60,
          .nature: 0.75,
          .history: 0.30,
          .science: 0.55,
          .emotions: 0.80,
          .business: 0.40,
          .culture: 0.65
        ]
      ) {
        print("Tapped profile")
      }
      .padding()
    }
  }
}

#Preview("Take Test") {
  GeometryReader { geometry in
    VStack {
      VocabularyProfileCard(
        screenSize: geometry.size,
        hasCompletedTest: false,
        vocabularyLevel: 0,
        overallScore: 0,
        categoryScores: [:]
      ) {
        print("Start test")
      }
      .padding()
    }
  }
}
