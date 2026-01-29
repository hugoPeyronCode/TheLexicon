//
//  ConnectionsGameView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

struct ConnectionsGameView: View {
  @Environment(\.dismiss) private var dismiss

  let dependencies: AppDependencies
  let date: Date?
  let infiniteLevel: Int?
  let customGroups: [WordGroup]?

  @State private var viewModel: ConnectionsGameViewModel
  @State private var showContinueButton: Bool = false
  @State private var showRestartAlert: Bool = false
  @State private var showExitAlert: Bool = false

  // Selection state
  @State private var selectedIndex: Int? = nil

  // Animation state for swap
  @State private var swapFirstIndex: Int? = nil
  @State private var swapSecondIndex: Int? = nil
  @State private var swapProgress: CGFloat = 0
  @State private var isSwapping: Bool = false

  // Haptic triggers
  @State private var selectionHapticTrigger: Bool = false
  @State private var swapCompletedTrigger: Bool = false

  // Streak celebration
  @State private var showStreakCelebration: Bool = false
  @State private var isNewStreakDay: Bool = false

  private let columns = 4

  private var isInfiniteMode: Bool {
    infiniteLevel != nil
  }

  private var isCustomMode: Bool {
    customGroups != nil
  }

  private var title: String {
    if customGroups != nil {
      return "Practice Level"
    }
    if let level = infiniteLevel {
      return "Level \(level)"
    }
    return "Connections"
  }

  init(dependencies: AppDependencies, date: Date = Date()) {
    self.dependencies = dependencies
    self.date = date
    self.infiniteLevel = nil
    self.customGroups = nil
    _viewModel = State(wrappedValue: ConnectionsGameViewModel(
      date: date,
      dailyProgressManager: dependencies.dailyProgressManager,
      puzzleStateManager: dependencies.puzzleStateManager,
      streakManager: dependencies.streakManager,
      infiniteModeProgressManager: dependencies.infiniteModeProgressManager,
      vocabularyProfileManager: dependencies.vocabularyProfileManager,
      levelDatabase: dependencies.levelDatabase
    ))
  }

  init(dependencies: AppDependencies, infiniteLevel: Int) {
    self.dependencies = dependencies
    self.date = nil
    self.infiniteLevel = infiniteLevel
    self.customGroups = nil
    _viewModel = State(wrappedValue: ConnectionsGameViewModel(
      infiniteLevel: infiniteLevel,
      dailyProgressManager: dependencies.dailyProgressManager,
      puzzleStateManager: dependencies.puzzleStateManager,
      streakManager: dependencies.streakManager,
      infiniteModeProgressManager: dependencies.infiniteModeProgressManager,
      vocabularyProfileManager: dependencies.vocabularyProfileManager,
      levelDatabase: dependencies.levelDatabase
    ))
  }

  init(dependencies: AppDependencies, customGroups: [WordGroup]) {
    self.dependencies = dependencies
    self.date = nil
    self.infiniteLevel = nil
    self.customGroups = customGroups
    _viewModel = State(wrappedValue: ConnectionsGameViewModel(
      customGroups: customGroups,
      dailyProgressManager: dependencies.dailyProgressManager,
      puzzleStateManager: dependencies.puzzleStateManager,
      streakManager: dependencies.streakManager,
      infiniteModeProgressManager: dependencies.infiniteModeProgressManager,
      vocabularyProfileManager: dependencies.vocabularyProfileManager,
      levelDatabase: dependencies.levelDatabase
    ))
  }

  // Determine if scrolling is needed (more than 6 rows)
  private var needsScrolling: Bool {
    viewModel.totalRows > 6
  }

  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        ZStack(alignment: .bottom) {
          // Main game content
          VStack(spacing: 0) {
            if needsScrolling {
              // Scrollable grid for large levels
              ScrollView {
                wordGrid(screenSize: geometry.size)
                  .padding(AppLayout.Padding.md(geometry.size))
              }
            } else {
              // Non-scrollable grid for small levels
              Spacer()
              wordGrid(screenSize: geometry.size)
                .padding(.horizontal, AppLayout.Padding.md(geometry.size))
              Spacer()
            }
          }

          // Continue button overlay (appears from bottom when game won)
          if viewModel.isGameWon {
            continueButton(screenSize: geometry.size)
              .transition(.move(edge: .bottom).combined(with: .opacity))
          }
        }
      }
      .scrollIndicators(.hidden)
      .background(AppColors.backgroundPrimary)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        // Leading: Exit button
        ToolbarItem(placement: .topBarLeading) {
          Button {
            showExitAlert = true
          } label: {
            Image(systemName: "xmark")
          }
        }

        // Center: Title
        ToolbarItem(placement: .principal) {
          VStack(spacing: 0) {
            if isInfiniteMode {
              Text("Infinite Mode")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            }
            Text(title)
              .fontWeight(.bold)
              .fontDesign(.serif)
          }
        }

        // Trailing: Progress indicator
        ToolbarItem(placement: .topBarTrailing) {
          Text("\(viewModel.completedRows.count)/\(viewModel.totalRows)")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(AppColors.textSecondary)
            .contentTransition(.numericText())
        }
      }
      .toolbar {
        // Bottom toolbar (hidden when game won)
        ToolbarItemGroup(placement: .bottomBar) {
          if !viewModel.isGameWon {
            Button {
              viewModel.shuffleWords()
            } label: {
              Label("Shuffle", systemImage: "shuffle")
            }

            Button {
              showRestartAlert = true
            } label: {
              Label("Restart", systemImage: "arrow.counterclockwise")
            }

            Spacer()
          }
        }
      }
      .alert("Restart Game?", isPresented: $showRestartAlert) {
        Button("Cancel", role: .cancel) { }
        Button("Restart", role: .destructive) {
          viewModel.restart()
        }
      } message: {
        Text("Your progress will be lost. Are you sure you want to restart?")
      }
      .alert("Exit Game?", isPresented: $showExitAlert) {
        Button("Cancel", role: .cancel) { }
        Button("Exit", role: .destructive) {
          dismiss()
        }
      } message: {
        Text(isInfiniteMode || isCustomMode ? "Your progress will not be saved." : "Your current progress will be saved. You can continue later.")
      }
    }
    // Haptic feedback triggers
    .sensoryFeedback(.impact(weight: .light), trigger: selectionHapticTrigger)
    .sensoryFeedback(.impact(weight: .medium), trigger: swapCompletedTrigger)
    .sensoryFeedback(.success, trigger: viewModel.isGameWon)
    .onChange(of: viewModel.isGameWon) { _, isWon in
      if isWon {
        // Record completion and check if this is a new streak day
        isNewStreakDay = dependencies.streakManager.recordCompletion()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
          showContinueButton = true
        }
      }
    }
    .fullScreenCover(isPresented: $showStreakCelebration, onDismiss: {
      dismiss()
    }) {
      StreakCelebrationView(
        streakCount: dependencies.streakManager.currentStreak,
        longestStreak: dependencies.streakManager.longestStreak,
        isNewStreak: isNewStreakDay
      )
    }
  }

  // MARK: - Word Grid

  @ViewBuilder
  private func wordGrid(screenSize: CGSize) -> some View {
    let cardHeight = screenSize.width * 0.14
    let horizontalPadding = AppLayout.Padding.md(screenSize) * 2
    let totalSpacing = AppLayout.Spacing.xs(screenSize) * CGFloat(columns - 1)
    let cardWidth = (screenSize.width - horizontalPadding - totalSpacing) / CGFloat(columns)
    let spacing = AppLayout.Spacing.xs(screenSize)
    let labelHeight = AppLayout.Spacing.lg(screenSize)

    VStack(spacing: spacing) {
      ForEach(0..<viewModel.totalRows, id: \.self) { row in
        VStack(spacing: AppLayout.Spacing.xxs(screenSize)) {
          // Family label (shown when row is completed)
          rowLabel(row: row, screenSize: screenSize, height: labelHeight)

          // Row of cards
          HStack(spacing: spacing) {
            ForEach(0..<columns, id: \.self) { col in
              let index = row * columns + col
              if index < viewModel.words.count {
                wordCardView(
                  index: index,
                  row: row,
                  screenSize: screenSize,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                  spacing: spacing,
                  labelHeight: labelHeight
                )
              }
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  private func rowLabel(row: Int, screenSize: CGSize, height: CGFloat) -> some View {
    if let completedRow = viewModel.completedRow(for: row) {
      Text(completedRow.theme.uppercased())
        .font(AppFonts.caption(screenSize))
        .fontWeight(.bold)
        .foregroundStyle(completedRow.color)
        .frame(height: height)
        .transition(.opacity.combined(with: .scale))
    } else {
      Color.clear
        .frame(height: height)
    }
  }

  @ViewBuilder
  private func wordCardView(
    index: Int,
    row: Int,
    screenSize: CGSize,
    cardHeight: CGFloat,
    cardWidth: CGFloat,
    spacing: CGFloat,
    labelHeight: CGFloat
  ) -> some View {
    let word = viewModel.words[index]
    let isCompleted = viewModel.isRowCompleted(row)
    let completedRow = viewModel.completedRow(for: row)
    let isRecentlyCompleted = viewModel.recentlyCompletedRow == row
    let isSelected = selectedIndex == index
    let canSelect = viewModel.canDrag(index: index) && !isSwapping

    // Calculate swap animation offset
    let animationOffset = calculateSwapOffset(
      for: index,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      spacing: spacing,
      labelHeight: labelHeight
    )

    cardContent(
      word: word,
      isCompleted: isCompleted,
      completedRow: completedRow,
      isSelected: isSelected,
      screenSize: screenSize,
      cardHeight: cardHeight
    )
    .scaleEffect(isSelected ? 1.08 : (isRecentlyCompleted ? 1.02 : 1.0))
    .shadow(
      color: isSelected ? Color.black.opacity(0.2) : Color.clear,
      radius: isSelected ? 8 : 0,
      y: isSelected ? 4 : 0
    )
    .offset(animationOffset)
    .zIndex(isSwappingCard(index) ? 100 : 0)
    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isSelected)
    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRecentlyCompleted)
    .onTapGesture {
      handleCardTap(index: index, canSelect: canSelect)
    }
  }

  private func isSwappingCard(_ index: Int) -> Bool {
    swapFirstIndex == index || swapSecondIndex == index
  }

  private func calculateSwapOffset(
    for index: Int,
    cardWidth: CGFloat,
    cardHeight: CGFloat,
    spacing: CGFloat,
    labelHeight: CGFloat
  ) -> CGSize {
    guard isSwapping else { return .zero }

    let rowHeight = cardHeight + labelHeight + AppLayout.Spacing.xxs(.zero)

    // First card moving to second position
    if index == swapFirstIndex, let targetIndex = swapSecondIndex {
      let fromRow = index / columns
      let fromCol = index % columns
      let toRow = targetIndex / columns
      let toCol = targetIndex % columns

      let deltaX = CGFloat(toCol - fromCol) * (cardWidth + spacing)
      let deltaY = CGFloat(toRow - fromRow) * (rowHeight + spacing)

      return CGSize(
        width: deltaX * swapProgress,
        height: deltaY * swapProgress
      )
    }

    // Second card moving to first position
    if index == swapSecondIndex, let targetIndex = swapFirstIndex {
      let fromRow = index / columns
      let fromCol = index % columns
      let toRow = targetIndex / columns
      let toCol = targetIndex % columns

      let deltaX = CGFloat(toCol - fromCol) * (cardWidth + spacing)
      let deltaY = CGFloat(toRow - fromRow) * (rowHeight + spacing)

      return CGSize(
        width: deltaX * swapProgress,
        height: deltaY * swapProgress
      )
    }

    return .zero
  }

  private func handleCardTap(index: Int, canSelect: Bool) {
    guard canSelect else { return }

    if let firstIndex = selectedIndex {
      // Second tap - perform swap
      if firstIndex == index {
        // Tapped same card - deselect
        selectedIndex = nil
        selectionHapticTrigger.toggle()
      } else if viewModel.canDrop(at: index) {
        // Start swap animation
        performAnimatedSwap(from: firstIndex, to: index)
      }
    } else {
      // First tap - select card
      selectedIndex = index
      selectionHapticTrigger.toggle()
    }
  }

  private func performAnimatedSwap(from firstIndex: Int, to secondIndex: Int) {
    // Setup animation state
    swapFirstIndex = firstIndex
    swapSecondIndex = secondIndex
    isSwapping = true
    selectedIndex = nil

    // Animate to swapped positions
    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
      swapProgress = 1.0
    }

    // After animation completes, perform the actual data swap
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      // Perform data swap
      viewModel.performSwap(from: firstIndex, to: secondIndex)

      // Trigger completion haptic
      swapCompletedTrigger.toggle()

      // Reset animation state
      swapProgress = 0
      swapFirstIndex = nil
      swapSecondIndex = nil
      isSwapping = false
    }
  }

  @ViewBuilder
  private func cardContent(
    word: Word,
    isCompleted: Bool,
    completedRow: CompletedRow?,
    isSelected: Bool,
    screenSize: CGSize,
    cardHeight: CGFloat
  ) -> some View {
    Text(word.text)
      .font(fontForWord(word.text, screenSize: screenSize))
      .fontWeight(.medium)
      .minimumScaleFactor(0.5)
      .lineLimit(1)
      .foregroundStyle(textColor(isCompleted: isCompleted))
      .padding(.horizontal, 4)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .frame(height: cardHeight)
      .background {
        RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium(screenSize))
          .fill(cardBackground(isCompleted: isCompleted, completedRow: completedRow))
      }
      .overlay {
        RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium(screenSize))
          .stroke(
            isSelected ? AppColors.accent : cardBorder(isCompleted: isCompleted, completedRow: completedRow),
            lineWidth: isSelected ? 3 : AppLayout.Stroke.thin(screenSize)
          )
      }
  }

  private func fontForWord(_ text: String, screenSize: CGSize) -> Font {
    // Use smaller font for longer words
    let length = text.count
    if length <= 6 {
      return AppFonts.body(screenSize)
    } else if length <= 9 {
      return AppFonts.footnote(screenSize)
    } else {
      return AppFonts.caption(screenSize)
    }
  }

  private func textColor(isCompleted: Bool) -> Color {
    if isCompleted {
      return AppColors.textInverse
    } else {
      return AppColors.textPrimary
    }
  }

  private func cardBackground(isCompleted: Bool, completedRow: CompletedRow?) -> Color {
    if isCompleted, let row = completedRow {
      return row.color
    } else {
      return AppColors.accentSubtle
    }
  }

  private func cardBorder(isCompleted: Bool, completedRow: CompletedRow?) -> Color {
    if isCompleted, let row = completedRow {
      return row.color
    } else {
      return AppColors.accentMuted
    }
  }

  // MARK: - Continue Button

  @ViewBuilder
  private func continueButton(screenSize: CGSize) -> some View {
    GlassEffectContainer {
      Button {
        handleContinue()
      } label: {
        HStack(spacing: 8) {
          Image(systemName: "checkmark.circle.fill")
          Text("Continue")
        }
        .fontDesign(.serif)
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundStyle(AppColors.textInverse)
        .frame(maxWidth: .infinity)
        .padding()
      }
      .tint(AppColors.stateSuccess)
      .buttonStyle(.glassProminent)
      .padding()
    }
  }

  private func handleContinue() {
    // Only show streak celebration for daily mode when it's a new streak day
    if !isInfiniteMode && !isCustomMode && isNewStreakDay {
      showStreakCelebration = true
    } else {
      dismiss()
    }
  }
}

// MARK: - Preview

#Preview {
  ConnectionsGameView(dependencies: .forPreview())
}
