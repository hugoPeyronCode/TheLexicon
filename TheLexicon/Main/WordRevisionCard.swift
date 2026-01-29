//
//  WordRevisionCard.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

struct WordRevisionCard: View {
  let screenSize: CGSize
  let dependencies: AppDependencies
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        // Icon
        ZStack {
          Circle()
            .fill(AppColors.accentSubtle)
            .frame(width: 50, height: 50)

          Image(systemName: "book.closed.fill")
            .font(.title2)
            .foregroundStyle(AppColors.accent)
        }

        // Content
        VStack(alignment: .leading, spacing: 4) {
          Text("Word Revision")
            .font(.headline)
            .fontWeight(.semibold)
            .fontDesign(.serif)
            .foregroundStyle(AppColors.textPrimary)

          Text("Master new vocabulary")
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)
      }
      .padding()
      .background {
        RoundedRectangle(cornerRadius: 16)
          .fill(AppColors.surfaceDefault)
      }
      .overlay {
        RoundedRectangle(cornerRadius: 16)
          .stroke(AppColors.borderMuted, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Word of the Day Card

struct WordOfTheDayCard: View {
  let screenSize: CGSize
  let word: WordDefinition?
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 12) {
        // Header
        HStack {
          HStack(spacing: 6) {
            Image(systemName: "sparkles")
              .foregroundStyle(AppColors.accent)
            Text("Word of the Day")
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundStyle(AppColors.accent)
          }

          Spacer()

          if let word = word {
            DifficultyIndicator(level: word.difficulty)
          }
        }

        if let word = word {
          // Word
          VStack(alignment: .leading, spacing: 4) {
            Text(word.word)
              .font(.title2)
              .fontWeight(.bold)
              .fontDesign(.serif)
              .foregroundStyle(AppColors.textPrimary)

            if let pronunciation = word.pronunciation {
              Text(pronunciation)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .italic()
            }
          }

          // Definition
          Text(word.definition)
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)

          // Category
          if let category = SemanticCategory(rawValue: word.category) {
            HStack(spacing: 4) {
              Image(systemName: category.icon)
                .font(.caption2)
              Text(category.rawValue)
                .font(.caption2)
            }
            .foregroundStyle(category.color)
          }
        } else {
          // Loading state
          Text("Loading...")
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background {
        RoundedRectangle(cornerRadius: 16)
          .fill(
            LinearGradient(
              colors: [
                AppColors.accentSubtle,
                AppColors.surfaceDefault
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      }
      .overlay {
        RoundedRectangle(cornerRadius: 16)
          .stroke(AppColors.accent.opacity(0.3), lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Difficulty Indicator

private struct DifficultyIndicator: View {
  let level: Int

  private var color: Color {
    switch level {
    case 1...4: return .green
    case 5...6: return .yellow
    case 7...8: return .orange
    case 9...10: return .red
    default: return .gray
    }
  }

  var body: some View {
    HStack(spacing: 2) {
      ForEach(0..<5, id: \.self) { index in
        Circle()
          .fill(index < (level / 2) ? color : color.opacity(0.2))
          .frame(width: 5, height: 5)
      }
    }
  }
}

// MARK: - Preview

#Preview("Word Revision Card") {
  WordRevisionCard(
    screenSize: CGSize(width: 393, height: 852),
    dependencies: .forPreview()
  ) {}
    .padding()
}

#Preview("Word of the Day Card") {
  WordOfTheDayCard(
    screenSize: CGSize(width: 393, height: 852),
    word: WordDefinition(
      word: "Ephemeral",
      definition: "Lasting for a very short time; transient and fleeting in nature",
      difficulty: 7,
      category: "Arts",
      pronunciation: "ih-FEM-er-ul",
      example: "The ephemeral beauty of cherry blossoms"
    )
  ) {}
    .padding()
}
