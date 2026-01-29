//
//  WordRevisionView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

// MARK: - Filter Mode

enum WordRevisionFilter: Equatable {
  case all
  case category(SemanticCategory)
  case wantToLearn

  var displayName: String {
    switch self {
    case .all:
      return "All Words"
    case .category(let cat):
      return cat.rawValue
    case .wantToLearn:
      return "Want to Learn"
    }
  }
}

struct WordRevisionView: View {
  @Environment(\.dismiss) private var dismiss

  let dependencies: AppDependencies

  @State private var currentPage: Int = 0
  @State private var selectedFilter: WordRevisionFilter = .all
  @State private var showFilters: Bool = false
  @State private var showCustomLevelAlert: Bool = false
  @State private var showCustomGame: Bool = false
  @State private var customGroups: [WordGroup] = []
  @State private var shuffledWords: [WordDefinition] = []
  @State private var hasInitialized: Bool = false
  @State private var swipeCount: Int = 0 // Track swipes to hide hint

  private var wantToLearnManager: WantToLearnManager {
    dependencies.wantToLearnManager
  }

  private var wordDatabase: WordDatabase {
    dependencies.wordDatabase
  }

  private var filteredWords: [WordDefinition] {
    // Use ALL words from the database
    let allWords = wordDatabase.all

    switch selectedFilter {
    case .all:
      return allWords
    case .category(let category):
      return allWords.filter { $0.category == category.rawValue }
    case .wantToLearn:
      let wantToLearnIds = Set(wantToLearnManager.pendingWords.map { $0.wordId })
      return allWords.filter { wantToLearnIds.contains($0.id) }
    }
  }

  var body: some View {
    NavigationStack {
      GeometryReader { screen in
        VStack(spacing: 0) {
          // Progress header
          progressHeader

          // TikTok-style scrolling content
          if shuffledWords.isEmpty {
            emptyState
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else {
            scrollingContent(screen: screen)
          }

          // Bottom controls
          bottomControls
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
          HStack(spacing: 12) {
            // Shuffle button
            Button {
              shuffleWords()
            } label: {
              Image(systemName: "shuffle")
            }

            // Filter button
            Button {
              showFilters.toggle()
            } label: {
              Image(systemName: selectedFilter != .all ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }
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
        ConnectionsGameView(dependencies: dependencies, customGroups: customGroups)
      }
      .onChange(of: wantToLearnManager.pendingCount) { _, newCount in
        if newCount >= WantToLearnManager.minimumWordsForLevel && newCount % 4 == 0 {
          showCustomLevelAlert = true
        }
      }
      .onChange(of: selectedFilter) { _, _ in
        shuffleWords()
        currentPage = 0
      }
      .onAppear {
        if !hasInitialized {
          shuffleWords()
          hasInitialized = true
        }
      }
    }
  }

  // MARK: - Scrolling Content

  private func scrollingContent(screen: GeometryProxy) -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      LazyVStack(spacing: 0) {
        ForEach(Array(shuffledWords.enumerated()), id: \.element.id) { index, word in
          WordCardView(
            word: word,
            isMarked: wantToLearnManager.isMarked(word.id),
            onToggleMark: {
              wantToLearnManager.toggleWord(word.id)
            }
          )
          .frame(height: screen.size.height - 200)
          .containerRelativeFrame(.vertical)
          .id(index)
        }
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.paging)
    .scrollPosition(id: Binding(
      get: { currentPage },
      set: { newValue in
        if let newValue {
          currentPage = newValue
          // Track swipes for hiding the hint
          if swipeCount < 3 {
            withAnimation {
              swipeCount += 1
            }
          }
        }
      }
    ))
    .sensoryFeedback(.impact(flexibility: .soft), trigger: currentPage)
  }

  // MARK: - Progress Header

  private var progressHeader: some View {
    VStack(spacing: 8) {
      HStack {
        Text("\(currentPage + 1) / \(shuffledWords.count)")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)
          .contentTransition(.numericText())

        Spacer()

        // Want to learn count badge
        if wantToLearnManager.pendingCount > 0 {
          HStack(spacing: 4) {
            Image(systemName: "bookmark.fill")
              .font(.caption2)
            Text("\(wantToLearnManager.pendingCount)")
              .font(.caption)
              .fontWeight(.semibold)
              .contentTransition(.numericText())
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
            .frame(width: geo.size.width * CGFloat(currentPage + 1) / CGFloat(max(shuffledWords.count, 1)), height: 4)
            .animation(.easeInOut(duration: 0.2), value: currentPage)
        }
      }
      .frame(height: 4)
    }
    .padding(.horizontal)
    .padding(.top, 8)
  }

  // MARK: - Bottom Controls

  private var bottomControls: some View {
    VStack(spacing: 12) {
      // Swipe hint (hidden after 3 swipes)
      if swipeCount < 3 {
        HStack(spacing: 4) {
          Image(systemName: "arrow.up.arrow.down")
          Text("Swipe to browse")
        }
        .font(.caption)
        .foregroundStyle(AppColors.textSecondary)
        .transition(.opacity)
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
        // Want to Learn section
        Section {
          Button {
            selectedFilter = .wantToLearn
            showFilters = false
          } label: {
            HStack {
              Image(systemName: "bookmark.fill")
                .foregroundStyle(AppColors.accent)
                .frame(width: 24)
              Text("Want to Learn")
              Spacer()
              Text("\(wantToLearnManager.pendingCount)")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
              if selectedFilter == .wantToLearn {
                Image(systemName: "checkmark")
                  .foregroundStyle(AppColors.accent)
              }
            }
          }
          .foregroundStyle(AppColors.textPrimary)
        } header: {
          Text("Learning")
        }

        Section("Category") {
          Button {
            selectedFilter = .all
            showFilters = false
          } label: {
            HStack {
              Image(systemName: "square.grid.2x2")
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 24)
              Text("All Words")
              Spacer()
              Text("\(wordDatabase.all.count)")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
              if selectedFilter == .all {
                Image(systemName: "checkmark")
                  .foregroundStyle(AppColors.accent)
              }
            }
          }
          .foregroundStyle(AppColors.textPrimary)

          ForEach(SemanticCategory.allCases, id: \.self) { category in
            let count = wordDatabase.all.filter { $0.category == category.rawValue }.count
            Button {
              selectedFilter = .category(category)
              showFilters = false
            } label: {
              HStack {
                Image(systemName: category.icon)
                  .foregroundStyle(category.color)
                  .frame(width: 24)
                Text(category.rawValue)
                Spacer()
                Text("\(count)")
                  .font(.caption)
                  .foregroundStyle(AppColors.textSecondary)
                if case .category(let selected) = selectedFilter, selected == category {
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
    .presentationDetents([.medium, .large])
  }

  // MARK: - Empty State

  private var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: selectedFilter == .wantToLearn ? "bookmark" : "text.book.closed")
        .font(.system(size: 60))
        .foregroundStyle(AppColors.textSecondary)

      Text(selectedFilter == .wantToLearn ? "No words to learn yet" : "No words found")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      Text(selectedFilter == .wantToLearn ? "Tap the bookmark icon on any word to add it here" : "Try selecting a different category")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }
  }

  // MARK: - Actions

  private func shuffleWords() {
    shuffledWords = filteredWords.shuffled()
  }
}

// MARK: - Word Card View

private struct WordCardView: View {
  let word: WordDefinition
  let isMarked: Bool
  let onToggleMark: () -> Void

  @State private var showDefinition: Bool = false

  private var category: SemanticCategory? {
    SemanticCategory(rawValue: word.category)
  }

  var body: some View {
    VStack(spacing: 16) {
      // Card
      ZStack {
        // Card background
        RoundedRectangle(cornerRadius: 24)
          .fill(AppColors.surfaceDefault)
          .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

        // Card content
        VStack(spacing: 0) {
          if !showDefinition {
            frontSide
          } else {
            backSide
          }
        }
      }
      .overlay {
        RoundedRectangle(cornerRadius: 24)
          .stroke(isMarked ? AppColors.accent : AppColors.borderMuted, lineWidth: isMarked ? 2 : 1)
      }
      .contentShape(Rectangle())
      .onTapGesture {
        withAnimation(.spring(response: 0.3)) {
          showDefinition.toggle()
        }
      }

      // Bookmark button at bottom (fixed, not scrolling with card content)
      Button {
        onToggleMark()
      } label: {
        HStack(spacing: 8) {
          Image(systemName: isMarked ? "bookmark.fill" : "bookmark")
            .font(.title3)
          Text(isMarked ? "Added to learning list" : "Add to learning list")
            .font(.subheadline)
            .fontWeight(.medium)
        }
        .foregroundStyle(isMarked ? .white : AppColors.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
          RoundedRectangle(cornerRadius: 14)
            .fill(isMarked ? AppColors.accent : AppColors.surfaceDefault)
        }
        .overlay {
          RoundedRectangle(cornerRadius: 14)
            .stroke(isMarked ? AppColors.accent : AppColors.borderMuted, lineWidth: 1)
        }
      }
      .sensoryFeedback(.impact(flexibility: .soft), trigger: isMarked)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
  }

  private var frontSide: some View {
    VStack(spacing: 24) {
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
        .font(.system(size: 42, weight: .bold, design: .serif))
        .foregroundStyle(AppColors.textPrimary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      // Pronunciation
      if let pronunciation = word.pronunciation {
        Text(pronunciation)
          .font(.title3)
          .foregroundStyle(AppColors.textSecondary)
          .italic()
      }

      // Difficulty
      DifficultyIndicator(level: word.difficulty)

      Spacer()

      // Hint
      HStack(spacing: 4) {
        Image(systemName: "hand.tap")
        Text("Tap to reveal definition")
      }
      .font(.caption)
      .foregroundStyle(AppColors.textSecondary)
      .padding(.bottom, 16)
    }
    .padding()
  }

  private var backSide: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        // Header
        VStack(alignment: .leading, spacing: 8) {
          Text(word.word)
            .font(.system(size: 32, weight: .bold, design: .serif))
            .foregroundStyle(AppColors.textPrimary)

          HStack(spacing: 12) {
            if let pronunciation = word.pronunciation {
              Text(pronunciation)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .italic()
            }

            DifficultyIndicator(level: word.difficulty)
          }
        }

        Divider()

        // Definition
        VStack(alignment: .leading, spacing: 8) {
          Label("Definition", systemImage: "text.quote")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.textSecondary)

          Text(word.definition)
            .font(.title3)
            .foregroundStyle(AppColors.textPrimary)
            .lineSpacing(4)
        }

        // Example
        if let example = word.example {
          VStack(alignment: .leading, spacing: 8) {
            Label("Example", systemImage: "quote.bubble")
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

        Spacer(minLength: 16)

        // Hint to tap to hide
        HStack {
          Spacer()
          HStack(spacing: 4) {
            Image(systemName: "hand.tap")
            Text("Tap to hide")
          }
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)
          Spacer()
        }
      }
      .padding(24)
    }
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

  private var label: String {
    switch level {
    case 1...4: return "Easy"
    case 5...6: return "Medium"
    case 7...8: return "Hard"
    case 9...10: return "Expert"
    default: return "Unknown"
    }
  }

  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<5, id: \.self) { index in
        Circle()
          .fill(index < (level + 1) / 2 ? color : color.opacity(0.2))
          .frame(width: 8, height: 8)
      }

      Text(label)
        .font(.caption2)
        .foregroundStyle(color)
        .padding(.leading, 4)
    }
  }
}

// MARK: - Preview

#Preview {
  WordRevisionView(dependencies: .forPreview())
}
