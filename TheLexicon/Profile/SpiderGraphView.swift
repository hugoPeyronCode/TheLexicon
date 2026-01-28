//
//  SpiderGraphView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

struct SpiderGraphView: View {
  let scores: [SemanticCategory: CGFloat] // Normalized 0-1
  let size: CGFloat
  let showLabels: Bool
  let animated: Bool

  @State private var animationProgress: CGFloat = 0

  private let categories = SemanticCategory.allCases
  private let levels = 5 // Number of concentric rings

  init(
    scores: [SemanticCategory: CGFloat],
    size: CGFloat = 200,
    showLabels: Bool = true,
    animated: Bool = true
  ) {
    self.scores = scores
    self.size = size
    self.showLabels = showLabels
    self.animated = animated
  }

  var body: some View {
    ZStack {
      // Background grid
      spiderGrid

      // Data polygon
      dataPolygon

      // Category labels
      if showLabels {
        categoryLabels
      }
    }
    .frame(width: size + (showLabels ? 80 : 0), height: size + (showLabels ? 80 : 0))
    .onAppear {
      if animated {
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
          animationProgress = 1.0
        }
      } else {
        animationProgress = 1.0
      }
    }
  }

  // MARK: - Spider Grid

  private var spiderGrid: some View {
    ZStack {
      // Concentric polygons
      ForEach(1...levels, id: \.self) { level in
        let scale = CGFloat(level) / CGFloat(levels)
        polygonPath(scale: scale)
          .stroke(AppColors.borderMuted, lineWidth: 1)
      }

      // Radial lines from center to each vertex
      ForEach(0..<categories.count, id: \.self) { index in
        radialLine(index: index)
          .stroke(AppColors.borderMuted, lineWidth: 0.5)
      }
    }
  }

  // MARK: - Data Polygon

  private var dataPolygon: some View {
    ZStack {
      // Filled area
      dataPath
        .fill(
          LinearGradient(
            colors: [
              AppColors.accent.opacity(0.3),
              AppColors.accent.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )

      // Stroke
      dataPath
        .stroke(AppColors.accent, lineWidth: 2)

      // Data points
      ForEach(0..<categories.count, id: \.self) { index in
        let category = categories[index]
        let score = scores[category] ?? 0
        let point = pointPosition(index: index, value: score * animationProgress)

        Circle()
          .fill(AppColors.accent)
          .frame(width: 8, height: 8)
          .position(point)
      }
    }
  }

  private var dataPath: Path {
    Path { path in
      for (index, category) in categories.enumerated() {
        let score = scores[category] ?? 0
        let point = pointPosition(index: index, value: score * animationProgress)

        if index == 0 {
          path.move(to: point)
        } else {
          path.addLine(to: point)
        }
      }
      path.closeSubpath()
    }
  }

  // MARK: - Category Labels

  private var categoryLabels: some View {
    ForEach(0..<categories.count, id: \.self) { index in
      let category = categories[index]
      let labelPosition = labelPosition(index: index)

      VStack(spacing: 2) {
        Image(systemName: category.icon)
          .font(.caption)
          .foregroundStyle(category.color)

        Text(category.rawValue)
          .font(.system(size: 9))
          .fontWeight(.medium)
          .foregroundStyle(AppColors.textSecondary)
      }
      .position(labelPosition)
    }
  }

  // MARK: - Geometry Helpers

  private func polygonPath(scale: CGFloat) -> Path {
    Path { path in
      for index in 0..<categories.count {
        let point = pointPosition(index: index, value: scale)

        if index == 0 {
          path.move(to: point)
        } else {
          path.addLine(to: point)
        }
      }
      path.closeSubpath()
    }
  }

  private func radialLine(index: Int) -> Path {
    Path { path in
      let center = CGPoint(x: size / 2, y: size / 2)
      let endPoint = pointPosition(index: index, value: 1.0)

      path.move(to: center)
      path.addLine(to: endPoint)
    }
  }

  private func pointPosition(index: Int, value: CGFloat) -> CGPoint {
    let center = CGPoint(x: size / 2, y: size / 2)
    let radius = (size / 2) * value
    let angle = angleForIndex(index) - .pi / 2 // Start from top

    return CGPoint(
      x: center.x + radius * cos(angle),
      y: center.y + radius * sin(angle)
    )
  }

  private func labelPosition(index: Int) -> CGPoint {
    let center = CGPoint(x: (size + 80) / 2, y: (size + 80) / 2)
    let radius = (size / 2) + 35
    let angle = angleForIndex(index) - .pi / 2

    return CGPoint(
      x: center.x + radius * cos(angle),
      y: center.y + radius * sin(angle)
    )
  }

  private func angleForIndex(_ index: Int) -> CGFloat {
    let slice = (2 * .pi) / CGFloat(categories.count)
    return slice * CGFloat(index)
  }
}

// MARK: - Mini Spider Graph (for cards)

struct MiniSpiderGraphView: View {
  let scores: [SemanticCategory: CGFloat]
  let size: CGFloat

  private let categories = SemanticCategory.allCases

  var body: some View {
    ZStack {
      // Simple grid
      ForEach([0.5, 1.0], id: \.self) { scale in
        polygonPath(scale: CGFloat(scale))
          .stroke(AppColors.borderMuted.opacity(0.5), lineWidth: 0.5)
      }

      // Data area
      dataPath
        .fill(AppColors.accent.opacity(0.3))

      dataPath
        .stroke(AppColors.accent, lineWidth: 1.5)
    }
    .frame(width: size, height: size)
  }

  private var dataPath: Path {
    Path { path in
      for (index, category) in categories.enumerated() {
        let score = scores[category] ?? 0
        let point = pointPosition(index: index, value: score)

        if index == 0 {
          path.move(to: point)
        } else {
          path.addLine(to: point)
        }
      }
      path.closeSubpath()
    }
  }

  private func polygonPath(scale: CGFloat) -> Path {
    Path { path in
      for index in 0..<categories.count {
        let point = pointPosition(index: index, value: scale)

        if index == 0 {
          path.move(to: point)
        } else {
          path.addLine(to: point)
        }
      }
      path.closeSubpath()
    }
  }

  private func pointPosition(index: Int, value: CGFloat) -> CGPoint {
    let center = CGPoint(x: size / 2, y: size / 2)
    let radius = (size / 2 - 2) * value
    let slice = (2 * .pi) / CGFloat(categories.count)
    let angle = slice * CGFloat(index) - .pi / 2

    return CGPoint(
      x: center.x + radius * cos(angle),
      y: center.y + radius * sin(angle)
    )
  }
}

// MARK: - Preview

#Preview("Spider Graph") {
  VStack(spacing: 40) {
    SpiderGraphView(
      scores: [
        .technology: 0.45,
        .arts: 0.60,
        .nature: 0.75,
        .history: 0.30,
        .science: 0.55,
        .emotions: 0.80,
        .business: 0.40,
        .culture: 0.65
      ],
      size: 200
    )

    MiniSpiderGraphView(
      scores: [
        .technology: 0.45,
        .arts: 0.60,
        .nature: 0.75,
        .history: 0.30,
        .science: 0.55,
        .emotions: 0.80,
        .business: 0.40,
        .culture: 0.65
      ],
      size: 80
    )
  }
  .padding()
}

#Preview("Empty Graph") {
  SpiderGraphView(
    scores: [:],
    size: 200
  )
  .padding()
}
