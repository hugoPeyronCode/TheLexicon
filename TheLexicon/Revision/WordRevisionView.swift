//
//  WordRevisionView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

struct WordRevisionView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var currentIndex: Int = 0
  @State private var dragOffset: CGFloat = 0
  @State private var showDefinition: Bool = false
  @State private var selectedCategory: SemanticCategory?
  @State private var showFilters: Bool = false
  @State private var showCustomLevelAlert: Bool = false
  @State private var showCustomGame: Bool = false
  @State private var customGroups: [WordGroup] = []

  private var wantToLearnManager: WantToLearnManager {
    WantToLearnManager.shared
  }

  private var allWords: [WordDefinition] {
    var words = WordDatabase.shared.harderWords

    if let category = selectedCategory {
      words = words.filter { $0.category == category.rawValue }
    }

    return words
  }

  private var currentWord: WordDefinition? {
    guard currentIndex >= 0 && currentIndex < allWords.count else { return nil }
    return allWords[currentIndex]
  }

  private var isCurrentWordMarked: Bool {
    guard let word = currentWord else { return false }
    return wantToLearnManager.isMarked(word.id)
  }

  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        VStack(spacing: 0) {
          // Progress indicator
          progressHeader

          // Main card area
          ZStack {
            if let word = currentWord {
              WordCard(
                word: word,
                showDefinition: showDefinition,
                isMarked: isCurrentWordMarked,
                screenSize: geometry.size
              )
              .offset(x: dragOffset)
              .rotationEffect(.degrees(Double(dragOffset) / 20))
              .gesture(swipeGesture)
              .onTapGesture {
                withAnimation(.spring(response: 0.3)) {
                  showDefinition.toggle()
                }
              }
            } else {
              emptyState
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding()

          // Bottom controls
          bottomControls(screenSize: geometry.size)
        }
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
          Text("Word Revision")
            .fontWeight(.bold)
            .fontDesign(.serif)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showFilters.toggle()
          } label: {
            Image(systemName: selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
          }
        }
      }
      .sheet(isPresented: $showFilters) {
        filterSheet
      }
      .alert("Create Custom Level", isPresented: $showCustomLevelAlert) {
        Button("Create Level") {
          customGroups = wantToLearnManager.generateCustomLevel()
          showCustomGame = true
        }
        Button("Keep Learning", role: .cancel) {}
      } message: {
        Text("You have \(wantToLearnManager.pendingCount) words to learn. Would you like to create a custom level to practice them?")
      }
      .fullScreenCover(isPresented: $showCustomGame) {
        ConnectionsGameView(customGroups: customGroups)
      }
      .onChange(of: wantToLearnManager.pendingCount) { _, newCount in
        if newCount >= WantToLearnManager.minimumWordsForLevel && newCount % 4 == 0 {
          showCustomLevelAlert = true
        }
      }
    }
  }

  // MARK: - Progress Header

  private var progressHeader: some View {
    VStack(spacing: 8) {
      HStack {
        Text("\(currentIndex + 1) / \(allWords.count)")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)

        Spacer()

        // Want to learn count badge
        if wantToLearnManager.pendingCount > 0 {
          HStack(spacing: 4) {
            Image(systemName: "bookmark.fill")
              .font(.caption2)
            Text("\(wantToLearnManager.pendingCount)")
              .font(.caption)
              .fontWeight(.semibold)
          }
          .foregroundStyle(AppColors.accent)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background {
            Capsule()
              .fill(AppColors.accentSubtle)
          }
        }
      }

      // Progress bar
      GeometryReader { geo in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 2)
            .fill(AppColors.surfaceDefault)
            .frame(height: 4)

          RoundedRectangle(cornerRadius: 2)
            .fill(AppColors.accent)
            .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(max(allWords.count, 1)), height: 4)
        }
      }
      .frame(height: 4)
    }
    .padding()
  }

  // MARK: - Bottom Controls

  private func bottomControls(screenSize: CGSize) -> some View {
    VStack(spacing: 16) {
      // Swipe hint
      Text(showDefinition ? "Tap to hide definition" : "Tap to reveal definition")
        .font(.caption)
        .foregroundStyle(AppColors.textSecondary)

      // Action buttons
      HStack(spacing: 24) {
        // Previous button
        Button {
          goToPrevious()
        } label: {
          Image(systemName: "arrow.left.circle.fill")
            .font(.system(size: 44))
            .foregroundStyle(currentIndex > 0 ? AppColors.textSecondary : AppColors.borderMuted)
        }
        .disabled(currentIndex == 0)

        // Want to learn button
        Button {
          toggleWantToLearn()
        } label: {
          VStack(spacing: 4) {
            Image(systemName: isCurrentWordMarked ? "bookmark.fill" : "bookmark")
              .font(.system(size: 32))
              .foregroundStyle(isCurrentWordMarked ? AppColors.accent : AppColors.textSecondary)

            Text(isCurrentWordMarked ? "Marked" : "Learn")
              .font(.caption2)
              .foregroundStyle(isCurrentWordMarked ? AppColors.accent : AppColors.textSecondary)
          }
        }
        .frame(width: 60)

        // Next button
        Button {
          goToNext()
        } label: {
          Image(systemName: "arrow.right.circle.fill")
            .font(.system(size: 44))
            .foregroundStyle(currentIndex < allWords.count - 1 ? AppColors.accent : AppColors.borderMuted)
        }
        .disabled(currentIndex >= allWords.count - 1)
      }

      // Custom level prompt
      if wantToLearnManager.canCreateCustomLevel {
        Button {
          showCustomLevelAlert = true
        } label: {
          HStack {
            Image(systemName: "sparkles")
            Text("Create Custom Level (\(wantToLearnManager.pendingCount) words)")
          }
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(.white)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background {
            Capsule()
              .fill(AppColors.accent)
          }
        }
      }
    }
    .padding()
    .padding(.bottom, 8)
  }

  // MARK: - Filter Sheet

  private var filterSheet: some View {
    NavigationStack {
      List {
        Section("Category") {
          Button {
            selectedCategory = nil
            currentIndex = 0
            showFilters = false
          } label: {
            HStack {
              Text("All Categories")
              Spacer()
              if selectedCategory == nil {
                Image(systemName: "checkmark")
                  .foregroundStyle(AppColors.accent)
              }
            }
          }
          .foregroundStyle(AppColors.textPrimary)

          ForEach(SemanticCategory.allCases, id: \.self) { category in
            Button {
              selectedCategory = category
              currentIndex = 0
              showFilters = false
            } label: {
              HStack {
                Image(systemName: category.icon)
                  .foregroundStyle(category.color)
                  .frame(width: 24)
                Text(category.rawValue)
                Spacer()
                if selectedCategory == category {
                  Image(systemName: "checkmark")
                    .foregroundStyle(AppColors.accent)
                }
              }
            }
            .foregroundStyle(AppColors.textPrimary)
          }
        }
      }
      .navigationTitle("Filters")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            showFilters = false
          }
        }
      }
    }
    .presentationDetents([.medium])
  }

  // MARK: - Empty State

  private var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: "text.book.closed")
        .font(.system(size: 60))
        .foregroundStyle(AppColors.textSecondary)

      Text("No words found")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      Text("Try selecting a different category")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
    }
  }

  // MARK: - Swipe Gesture

  private var swipeGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        dragOffset = value.translation.width
      }
      .onEnded { value in
        let threshold: CGFloat = 100
        withAnimation(.spring(response: 0.3)) {
          if value.translation.width > threshold && currentIndex > 0 {
            goToPrevious()
          } else if value.translation.width < -threshold && currentIndex < allWords.count - 1 {
            goToNext()
          }
          dragOffset = 0
        }
      }
  }

  // MARK: - Actions

  private func goToNext() {
    withAnimation(.spring(response: 0.3)) {
      if currentIndex < allWords.count - 1 {
        currentIndex += 1
        showDefinition = false
      }
    }
  }

  private func goToPrevious() {
    withAnimation(.spring(response: 0.3)) {
      if currentIndex > 0 {
        currentIndex -= 1
        showDefinition = false
      }
    }
  }

  private func toggleWantToLearn() {
    guard let word = currentWord else { return }
    wantToLearnManager.toggleWord(word.id)
  }
}

// MARK: - Word Card

private struct WordCard: View {
  let word: WordDefinition
  let showDefinition: Bool
  let isMarked: Bool
  let screenSize: CGSize

  private var category: SemanticCategory? {
    SemanticCategory(rawValue: word.category)
  }

  var body: some View {
    VStack(spacing: 0) {
      // Front side (word only)
      if !showDefinition {
        frontSide
      } else {
        // Back side (with definition)
        backSide
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 24)
        .fill(AppColors.surfaceDefault)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    .overlay {
      RoundedRectangle(cornerRadius: 24)
        .stroke(isMarked ? AppColors.accent : AppColors.borderMuted, lineWidth: isMarked ? 2 : 1)
    }
    .overlay(alignment: .topTrailing) {
      if isMarked {
        Image(systemName: "bookmark.fill")
          .font(.title2)
          .foregroundStyle(AppColors.accent)
          .padding()
      }
    }
  }

  private var frontSide: some View {
    VStack(spacing: 20) {
      Spacer()

      // Category badge
      if let cat = category {
        HStack(spacing: 6) {
          Image(systemName: cat.icon)
          Text(cat.rawValue)
        }
        .font(.caption)
        .foregroundStyle(cat.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
          Capsule()
            .fill(cat.color.opacity(0.15))
        }
      }

      // Word
      Text(word.word)
        .font(.system(size: 36, weight: .bold, design: .serif))
        .foregroundStyle(AppColors.textPrimary)
        .multilineTextAlignment(.center)

      // Pronunciation
      if let pronunciation = word.pronunciation {
        Text(pronunciation)
          .font(.title3)
          .foregroundStyle(AppColors.textSecondary)
          .italic()
      }

      // Difficulty
      DifficultyDots(level: word.difficulty)

      Spacer()

      // Hint
      HStack(spacing: 4) {
        Image(systemName: "hand.tap")
        Text("Tap to reveal")
      }
      .font(.caption)
      .foregroundStyle(AppColors.textSecondary)
      .padding(.bottom, 20)
    }
    .padding()
  }

  private var backSide: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Header
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(word.word)
              .font(.title)
              .fontWeight(.bold)
              .fontDesign(.serif)
              .foregroundStyle(AppColors.textPrimary)

            if let pronunciation = word.pronunciation {
              Text(pronunciation)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .italic()
            }
          }

          Spacer()

          DifficultyDots(level: word.difficulty)
        }

        Divider()

        // Definition
        VStack(alignment: .leading, spacing: 8) {
          Text("Definition")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.textSecondary)

          Text(word.definition)
            .font(.body)
            .foregroundStyle(AppColors.textPrimary)
        }

        // Example
        if let example = word.example {
          VStack(alignment: .leading, spacing: 8) {
            Text("Example")
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundStyle(AppColors.textSecondary)

            Text("\"\(example)\"")
              .font(.body)
              .foregroundStyle(AppColors.textPrimary)
              .italic()
          }
        }

        // Category
        if let cat = category {
          HStack(spacing: 8) {
            Image(systemName: cat.icon)
              .foregroundStyle(cat.color)
            Text(cat.rawValue)
              .font(.subheadline)
              .foregroundStyle(AppColors.textSecondary)
          }
          .padding(.top, 8)
        }
      }
      .padding(24)
    }
  }
}

// MARK: - Difficulty Dots

private struct DifficultyDots: View {
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
    HStack(spacing: 4) {
      ForEach(0..<5, id: \.self) { index in
        Circle()
          .fill(index < (level + 1) / 2 ? color : color.opacity(0.2))
          .frame(width: 8, height: 8)
      }
    }
  }
}

// MARK: - Preview

#Preview {
  WordRevisionView()
}
