//
//  ProfileDetailView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

struct ProfileDetailView: View {
  @Environment(\.dismiss) private var dismiss

  let vocabularyLevel: Int
  let overallScore: Int
  let totalWordsLearned: Int
  let categoryScores: [SemanticCategory: CGFloat]

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 32) {
          // Header stats
          headerSection

          // Spider graph
          spiderGraphSection

          // Category breakdown
          categoryBreakdownSection

          // Tips section
          tipsSection
        }
        .padding()
      }
      .background(AppColors.backgroundPrimary)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
        }

        ToolbarItem(placement: .principal) {
          Text("Your Lexicon")
            .fontWeight(.bold)
            .fontDesign(.serif)
        }
      }
    }
  }

  // MARK: - Header Section

  private var headerSection: some View {
    HStack(spacing: 24) {
      // Level
      VStack(spacing: 4) {
        Text("\(vocabularyLevel)")
          .font(.system(size: 48, weight: .bold, design: .rounded))
          .foregroundStyle(AppColors.accent)
        Text("Level")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)
      }
      .frame(maxWidth: .infinity)

      // Divider
      Rectangle()
        .fill(AppColors.borderMuted)
        .frame(width: 1, height: 60)

      // Score
      VStack(spacing: 4) {
        Text("\(overallScore)")
          .font(.system(size: 48, weight: .bold, design: .rounded))
          .foregroundStyle(AppColors.textPrimary)
        Text("Score")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)
      }
      .frame(maxWidth: .infinity)

      // Divider
      Rectangle()
        .fill(AppColors.borderMuted)
        .frame(width: 1, height: 60)

      // Words
      VStack(spacing: 4) {
        Text("\(totalWordsLearned)")
          .font(.system(size: 48, weight: .bold, design: .rounded))
          .foregroundStyle(AppColors.textPrimary)
        Text("Words")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)
      }
      .frame(maxWidth: .infinity)
    }
    .padding()
    .background {
      RoundedRectangle(cornerRadius: 16)
        .fill(AppColors.surfaceDefault)
    }
  }

  // MARK: - Spider Graph Section

  private var spiderGraphSection: some View {
    VStack(spacing: 16) {
      Text("Vocabulary Map")
        .font(.headline)
        .fontDesign(.serif)
        .frame(maxWidth: .infinity, alignment: .leading)

      SpiderGraphView(
        scores: categoryScores,
        size: 220,
        showLabels: true,
        animated: true
      )
      .frame(maxWidth: .infinity)
      .padding(.vertical)
    }
  }

  // MARK: - Category Breakdown

  private var categoryBreakdownSection: some View {
    VStack(spacing: 16) {
      Text("Category Scores")
        .font(.headline)
        .fontDesign(.serif)
        .frame(maxWidth: .infinity, alignment: .leading)

      VStack(spacing: 12) {
        ForEach(SemanticCategory.allCases, id: \.self) { category in
          categoryRow(category)
        }
      }
    }
  }

  @ViewBuilder
  private func categoryRow(_ category: SemanticCategory) -> some View {
    let score = categoryScores[category] ?? 0
    let percentage = Int(score * 100)

    HStack(spacing: 12) {
      // Icon
      Image(systemName: category.icon)
        .font(.body)
        .foregroundStyle(category.color)
        .frame(width: 24)

      // Name
      Text(category.rawValue)
        .font(.subheadline)
        .foregroundStyle(AppColors.textPrimary)

      Spacer()

      // Progress bar
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 4)
            .fill(AppColors.surfaceDefault)
            .frame(height: 8)

          RoundedRectangle(cornerRadius: 4)
            .fill(category.color)
            .frame(width: geometry.size.width * score, height: 8)
        }
      }
      .frame(width: 100, height: 8)

      // Percentage
      Text("\(percentage)%")
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(AppColors.textSecondary)
        .frame(width: 40, alignment: .trailing)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background {
      RoundedRectangle(cornerRadius: 12)
        .fill(AppColors.surfaceDefault)
    }
  }

  // MARK: - Tips Section

  private var tipsSection: some View {
    VStack(spacing: 16) {
      Text("Improve Your Lexicon")
        .font(.headline)
        .fontDesign(.serif)
        .frame(maxWidth: .infinity, alignment: .leading)

      // Find weakest categories
      let weakestCategories = findWeakestCategories()

      if !weakestCategories.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
          Text("Focus on these areas:")
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)

          ForEach(weakestCategories, id: \.self) { category in
            HStack(spacing: 8) {
              Image(systemName: category.icon)
                .foregroundStyle(category.color)
              Text(category.rawValue)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
            }
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
          RoundedRectangle(cornerRadius: 12)
            .fill(AppColors.accentSubtle)
        }
      }

      Text("Play daily to improve your vocabulary across all categories. Longer streaks give bonus points!")
        .font(.caption)
        .foregroundStyle(AppColors.textSecondary)
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 12)
            .fill(AppColors.surfaceDefault)
        }
    }
  }

  private func findWeakestCategories() -> [SemanticCategory] {
    let sorted = categoryScores.sorted { $0.value < $1.value }
    return Array(sorted.prefix(3).map { $0.key })
  }
}

// MARK: - Preview

#Preview {
  ProfileDetailView(
    vocabularyLevel: 42,
    overallScore: 1250,
    totalWordsLearned: 324,
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
  )
}
