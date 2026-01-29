//
//  VocabularyTestView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

// MARK: - Test Word Model

struct TestWord {
  let word: String
  let definition: String
  let difficulty: Int // 1-10
  let category: SemanticCategory
  let options: [String] // 4 options including correct one
}

// MARK: - Test Data

struct VocabularyTestData {
  // Difficulty ladder: words get progressively harder
  static let words: [TestWord] = [
    // Level 1-2: Very Easy
    TestWord(
      word: "Happy",
      definition: "Feeling pleasure or contentment",
      difficulty: 1,
      category: .emotions,
      options: ["Feeling pleasure or contentment", "Feeling anger", "Feeling tired", "Feeling confused"]
    ),
    TestWord(
      word: "Tree",
      definition: "A perennial plant with a trunk",
      difficulty: 1,
      category: .nature,
      options: ["A type of fish", "A perennial plant with a trunk", "A musical instrument", "A building"]
    ),

    // Level 3-4: Easy
    TestWord(
      word: "Ambition",
      definition: "A strong desire to achieve something",
      difficulty: 3,
      category: .emotions,
      options: ["Fear of heights", "A strong desire to achieve something", "A type of medicine", "A musical style"]
    ),
    TestWord(
      word: "Algorithm",
      definition: "A step-by-step procedure for calculations",
      difficulty: 4,
      category: .technology,
      options: ["A step-by-step procedure for calculations", "A type of dance", "A chemical element", "A historical period"]
    ),

    // Level 5-6: Medium
    TestWord(
      word: "Ephemeral",
      definition: "Lasting for a very short time",
      difficulty: 5,
      category: .culture,
      options: ["Very large", "Lasting for a very short time", "Related to water", "Extremely bright"]
    ),
    TestWord(
      word: "Catalyst",
      definition: "Something that causes change without being affected",
      difficulty: 5,
      category: .science,
      options: ["A type of crystal", "Something that causes change without being affected", "An ancient weapon", "A musical note"]
    ),
    TestWord(
      word: "Paradigm",
      definition: "A typical example or model of something",
      difficulty: 6,
      category: .business,
      options: ["A type of graph", "A typical example or model of something", "A mathematical formula", "A type of architecture"]
    ),

    // Level 7-8: Hard
    TestWord(
      word: "Hegemony",
      definition: "Dominance of one group over others",
      difficulty: 7,
      category: .history,
      options: ["A type of geometry", "Dominance of one group over others", "A musical composition", "A natural phenomenon"]
    ),
    TestWord(
      word: "Sycophant",
      definition: "A person who flatters for personal gain",
      difficulty: 7,
      category: .culture,
      options: ["A type of elephant", "A person who flatters for personal gain", "An ancient artifact", "A scientific instrument"]
    ),
    TestWord(
      word: "Verisimilitude",
      definition: "The appearance of being true or real",
      difficulty: 8,
      category: .arts,
      options: ["The appearance of being true or real", "A type of measurement", "A philosophical concept about time", "A musical technique"]
    ),

    // Level 9-10: Expert
    TestWord(
      word: "Perspicacious",
      definition: "Having keen mental perception and understanding",
      difficulty: 9,
      category: .emotions,
      options: ["Relating to perspective", "Having keen mental perception and understanding", "Extremely cautious", "Very persuasive"]
    ),
    TestWord(
      word: "Sesquipedalian",
      definition: "Characterized by long words or using long words",
      difficulty: 9,
      category: .culture,
      options: ["Related to the number six", "Characterized by long words or using long words", "A type of anniversary", "Extremely tall"]
    ),
    TestWord(
      word: "Defenestration",
      definition: "The act of throwing someone out of a window",
      difficulty: 10,
      category: .history,
      options: ["The act of throwing someone out of a window", "A type of celebration", "The process of losing teeth", "A defensive strategy"]
    )
  ]
}

// MARK: - Vocabulary Test View

struct VocabularyTestView: View {
  @Environment(\.dismiss) private var dismiss

  let dependencies: AppDependencies

  @State private var currentWordIndex: Int = 0
  @State private var correctAnswers: Int = 0
  @State private var wrongAnswers: Int = 0
  @State private var categoryScores: [SemanticCategory: Int] = [:]
  @State private var isTestComplete: Bool = false
  @State private var selectedAnswer: String? = nil
  @State private var showingResult: Bool = false
  @State private var consecutiveWrong: Int = 0

  // Haptic triggers
  @State private var correctHaptic: Bool = false
  @State private var wrongHaptic: Bool = false

  private let maxWrongAnswers = 3 // Stop after 3 wrong answers

  private var currentWord: TestWord? {
    guard currentWordIndex < VocabularyTestData.words.count else { return nil }
    return VocabularyTestData.words[currentWordIndex]
  }

  private var progress: CGFloat {
    CGFloat(currentWordIndex) / CGFloat(VocabularyTestData.words.count)
  }

  var body: some View {
    NavigationStack {
      ZStack {
        AppColors.backgroundPrimary
          .ignoresSafeArea()

        if isTestComplete {
          testResultsView
        } else if let word = currentWord {
          testQuestionView(word: word)
        }
      }
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
          Text("Vocabulary Test")
            .fontWeight(.bold)
            .fontDesign(.serif)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Text("\(currentWordIndex + 1)/\(VocabularyTestData.words.count)")
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
        }
      }
    }
    .sensoryFeedback(.success, trigger: correctHaptic)
    .sensoryFeedback(.error, trigger: wrongHaptic)
  }

  // MARK: - Question View

  @ViewBuilder
  private func testQuestionView(word: TestWord) -> some View {
    VStack(spacing: 32) {
      // Progress bar
      ProgressView(value: progress)
        .tint(AppColors.accent)
        .padding(.horizontal)

      Spacer()

      // Word display
      VStack(spacing: 16) {
        Text("What does this word mean?")
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)

        Text(word.word)
          .font(.system(size: 36, weight: .bold, design: .serif))
          .foregroundStyle(AppColors.textPrimary)

        // Difficulty indicator
        HStack(spacing: 4) {
          ForEach(1...10, id: \.self) { level in
            Circle()
              .fill(level <= word.difficulty ? AppColors.accent : AppColors.borderMuted)
              .frame(width: 8, height: 8)
          }
        }
      }

      Spacer()

      // Answer options
      VStack(spacing: 12) {
        ForEach(word.options, id: \.self) { option in
          answerButton(option: option, correctAnswer: word.definition)
        }
      }
      .padding(.horizontal)

      Spacer()
    }
    .padding(.vertical)
  }

  @ViewBuilder
  private func answerButton(option: String, correctAnswer: String) -> some View {
    let isSelected = selectedAnswer == option
    let isCorrect = option == correctAnswer
    let showCorrect = showingResult && isCorrect
    let showWrong = showingResult && isSelected && !isCorrect

    Button {
      if !showingResult {
        selectAnswer(option, correctAnswer: correctAnswer)
      }
    } label: {
      Text(option)
        .font(.subheadline)
        .fontWeight(.medium)
        .multilineTextAlignment(.leading)
        .foregroundStyle(
          showCorrect ? .white :
            showWrong ? .white :
            AppColors.textPrimary
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 12)
            .fill(
              showCorrect ? AppColors.stateSuccess :
                showWrong ? AppColors.stateError :
                isSelected ? AppColors.accentSubtle :
                AppColors.surfaceDefault
            )
        }
        .overlay {
          RoundedRectangle(cornerRadius: 12)
            .stroke(
              showCorrect ? AppColors.stateSuccess :
                showWrong ? AppColors.stateError :
                isSelected ? AppColors.accent :
                AppColors.borderMuted,
              lineWidth: isSelected || showCorrect || showWrong ? 2 : 1
            )
        }
    }
    .disabled(showingResult)
  }

  // MARK: - Results View

  @ViewBuilder
  private var testResultsView: some View {
    VStack(spacing: 32) {
      Spacer()

      // Score display
      VStack(spacing: 16) {
        Image(systemName: "checkmark.seal.fill")
          .font(.system(size: 60))
          .foregroundStyle(AppColors.accent)

        Text("Test Complete!")
          .font(.title)
          .fontWeight(.bold)
          .fontDesign(.serif)

        Text("You answered \(correctAnswers) out of \(correctAnswers + wrongAnswers) correctly")
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)
      }

      // Score breakdown
      VStack(spacing: 16) {
        HStack(spacing: 32) {
          VStack {
            Text("\(calculateVocabularyLevel())")
              .font(.system(size: 48, weight: .bold, design: .rounded))
              .foregroundStyle(AppColors.accent)
            Text("Vocabulary Level")
              .font(.caption)
              .foregroundStyle(AppColors.textSecondary)
          }

          VStack {
            Text("\(calculateOverallScore())")
              .font(.system(size: 48, weight: .bold, design: .rounded))
              .foregroundStyle(AppColors.textPrimary)
            Text("Initial Score")
              .font(.caption)
              .foregroundStyle(AppColors.textSecondary)
          }
        }
      }

      Spacer()

      // Continue button
      Button {
        saveResultsAndDismiss()
      } label: {
        Text("Continue")
          .font(.headline)
          .fontWeight(.bold)
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background {
            RoundedRectangle(cornerRadius: 16)
              .fill(AppColors.accent)
          }
      }
      .padding(.horizontal, 40)
      .padding(.bottom, 40)
    }
  }

  // MARK: - Logic

  private func selectAnswer(_ answer: String, correctAnswer: String) {
    selectedAnswer = answer
    showingResult = true

    let isCorrect = answer == correctAnswer

    if isCorrect {
      correctAnswers += 1
      consecutiveWrong = 0
      correctHaptic.toggle()

      // Track category score
      if let word = currentWord {
        categoryScores[word.category, default: 0] += word.difficulty
      }
    } else {
      wrongAnswers += 1
      consecutiveWrong += 1
      wrongHaptic.toggle()
    }

    // Move to next question after delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      if wrongAnswers >= maxWrongAnswers || currentWordIndex >= VocabularyTestData.words.count - 1 {
        withAnimation {
          isTestComplete = true
        }
      } else {
        withAnimation {
          currentWordIndex += 1
          selectedAnswer = nil
          showingResult = false
        }
      }
    }
  }

  private func calculateVocabularyLevel() -> Int {
    // Based on how far they got and accuracy
    let progressFactor = CGFloat(currentWordIndex + 1) / CGFloat(VocabularyTestData.words.count)
    let accuracyFactor = CGFloat(correctAnswers) / CGFloat(max(correctAnswers + wrongAnswers, 1))

    let level = Int((progressFactor * 50 + accuracyFactor * 50))
    return min(max(level, 1), 100)
  }

  private func calculateOverallScore() -> Int {
    // Sum of difficulty levels for correct answers
    return categoryScores.values.reduce(0, +) * 10
  }

  private func saveResultsAndDismiss() {
    // Normalize category scores to 0-100 scale
    var normalizedScores: [SemanticCategory: Int] = [:]
    let maxCategoryScore = 30 // Rough max for any category

    for (category, score) in categoryScores {
      normalizedScores[category] = min(Int((CGFloat(score) / CGFloat(maxCategoryScore)) * 100), 100)
    }

    // Fill in missing categories with 0
    for category in SemanticCategory.allCases {
      if normalizedScores[category] == nil {
        normalizedScores[category] = 0
      }
    }

    dependencies.vocabularyProfileManager.completeInitialTest(
      score: calculateOverallScore(),
      categoryScores: normalizedScores
    )

    dismiss()
  }
}

// MARK: - Preview

#Preview {
  VocabularyTestView(dependencies: .forPreview())
}
