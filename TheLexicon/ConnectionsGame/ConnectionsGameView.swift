//
//  ConnectionsGameView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

struct ConnectionsGameView: View {
  @Environment(\.dismiss) private var dismiss

  let date: Date

  @State private var viewModel: ConnectionsGameViewModel
  @State private var showContinueButton: Bool = false
  @State private var showRestartAlert: Bool = false
  @State private var showExitAlert: Bool = false

  private let columns = 4

  init(date: Date = Date()) {
    self.date = date
    self._viewModel = State(initialValue: ConnectionsGameViewModel(date: date))
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

            // Bottom spacer for toolbar
            if viewModel.isGameWon {
              Color.clear
                .frame(height: AppLayout.Padding.lg(geometry.size) * 2 + 60)
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
          Text("Connections")
            .fontWeight(.bold)
            .fontDesign(.serif)
        }

        // Trailing: Progress indicator
        ToolbarItem(placement: .topBarTrailing) {
          Text("\(viewModel.completedRows.count)/\(viewModel.totalRows)")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(AppColors.textSecondary)
        }
      }
      .toolbar {
        // Bottom toolbar (hidden when game won)
        ToolbarItemGroup(placement: .bottomBar) {
          if !viewModel.isGameWon {
            Button {
              withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                viewModel.shuffleWords()
              }
            } label: {
              Label("Shuffle", systemImage: "shuffle")
            }
            .disabled(viewModel.isSwapping)

            Button {
              showRestartAlert = true
            } label: {
              Label("Restart", systemImage: "arrow.counterclockwise")
            }
            .disabled(viewModel.isSwapping)

            Spacer()

            if viewModel.selectedIndex != nil {
              Text("Tap another card to swap")
                .font(.caption)
                .foregroundStyle(AppColors.textMuted)
            }
          }
        }
      }
      .alert("Restart Game?", isPresented: $showRestartAlert) {
        Button("Cancel", role: .cancel) { }
        Button("Restart", role: .destructive) {
          withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            viewModel.restart()
          }
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
        Text("Your current progress will be saved. You can continue later.")
      }
    }
    // Haptic feedback triggers
    .sensoryFeedback(.selection, trigger: viewModel.selectedIndex)
    .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.swapInProgress)
    .sensoryFeedback(.success, trigger: viewModel.isGameWon)
    .onChange(of: viewModel.isGameWon) { _, isWon in
      if isWon {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
          showContinueButton = true
        }
      }
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
    let rowHeight = cardHeight + labelHeight + AppLayout.Spacing.xxs(screenSize)

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
                  rowHeight: rowHeight,
                  spacing: spacing
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
    rowHeight: CGFloat,
    spacing: CGFloat
  ) -> some View {
    let word = viewModel.words[index]
    let isSelected = viewModel.isSelected(at: index)
    let isCompleted = viewModel.isRowCompleted(row)
    let completedRow = viewModel.completedRow(for: row)
    let isRecentlyCompleted = viewModel.recentlyCompletedRow == row
    let isBeingSwapped = isSwappingCard(index)

    // Calculate swap offset
    let swapOffset = calculateSwapOffset(
      for: index,
      cardWidth: cardWidth,
      rowHeight: rowHeight,
      spacing: spacing
    )

    Button {
      viewModel.selectCard(at: index)
    } label: {
      Text(word.text)
        .font(AppFonts.body(screenSize))
        .fontWeight(.medium)
        .foregroundStyle(textColor(isCompleted: isCompleted, isSelected: isSelected))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
          RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium(screenSize))
            .fill(cardBackground(isCompleted: isCompleted, isSelected: isSelected, completedRow: completedRow))
        }
        .overlay {
          RoundedRectangle(cornerRadius: AppLayout.CornerRadius.medium(screenSize))
            .stroke(
              cardBorder(isCompleted: isCompleted, isSelected: isSelected, completedRow: completedRow),
              lineWidth: isSelected ? AppLayout.Stroke.thick(screenSize) : AppLayout.Stroke.thin(screenSize)
            )
        }
    }
    .buttonStyle(.plain)
    .frame(height: cardHeight)
    .zIndex(isBeingSwapped ? 100 : 0)
    .offset(swapOffset)
    .scaleEffect(isBeingSwapped ? 1.08 : (isRecentlyCompleted ? 1.05 : (isSelected ? 1.03 : 1.0)))
    .shadow(
      color: isBeingSwapped ? Color.black.opacity(0.2) : Color.clear,
      radius: isBeingSwapped ? 8 : 0,
      y: isBeingSwapped ? 4 : 0
    )
    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: swapOffset)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isBeingSwapped)
    .animation(.easeInOut(duration: 0.15), value: isSelected)
    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRecentlyCompleted)
    .disabled(isCompleted || viewModel.isSwapping)
  }

  private func textColor(isCompleted: Bool, isSelected: Bool) -> Color {
    if isCompleted {
      return AppColors.textInverse
    } else if isSelected {
      return AppColors.buttonPrimaryText
    } else {
      return AppColors.textPrimary
    }
  }

  private func isSwappingCard(_ index: Int) -> Bool {
    guard let swap = viewModel.swapInProgress else { return false }
    return index == swap.fromIndex || index == swap.toIndex
  }

  private func calculateSwapOffset(
    for index: Int,
    cardWidth: CGFloat,
    rowHeight: CGFloat,
    spacing: CGFloat
  ) -> CGSize {
    guard let swap = viewModel.swapInProgress else {
      return .zero
    }

    let fromRow = swap.fromIndex / columns
    let fromCol = swap.fromIndex % columns
    let toRow = swap.toIndex / columns
    let toCol = swap.toIndex % columns

    // Calculate the distance between cards
    let colDiff = CGFloat(toCol - fromCol)
    let rowDiff = CGFloat(toRow - fromRow)

    let horizontalDistance = colDiff * (cardWidth + spacing)
    let verticalDistance = rowDiff * (rowHeight + spacing)

    if index == swap.fromIndex {
      // Move from -> to position
      return CGSize(width: horizontalDistance, height: verticalDistance)
    } else if index == swap.toIndex {
      // Move to -> from position (opposite direction)
      return CGSize(width: -horizontalDistance, height: -verticalDistance)
    }

    return .zero
  }

  private func cardBackground(isCompleted: Bool, isSelected: Bool, completedRow: CompletedRow?) -> Color {
    if isCompleted, let row = completedRow {
      return row.color
    } else if isSelected {
      return AppColors.accent
    } else {
      return AppColors.surfaceDefault
    }
  }

  private func cardBorder(isCompleted: Bool, isSelected: Bool, completedRow: CompletedRow?) -> Color {
    if isCompleted, let row = completedRow {
      return row.color
    } else if isSelected {
      return AppColors.accent
    } else {
      return AppColors.borderDefault
    }
  }

  // MARK: - Continue Button

  @ViewBuilder
  private func continueButton(screenSize: CGSize) -> some View {
    GlassEffectContainer {
      Button {
        dismiss()
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
}

// MARK: - Preview

#Preview {
  ConnectionsGameView()
    .withPreviewContainer()
}
