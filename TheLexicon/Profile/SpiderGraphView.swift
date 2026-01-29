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
  private let labelPadding: CGFloat = 50

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

  private var totalSize: CGFloat {
    size + (showLabels ? labelPadding * 2 : 0)
  }

  var body: some View {
    ZStack {
      // Graph canvas
      Canvas { context, canvasSize in
        let graphCenter = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let graphRadius = size / 2

        // Draw grid
        drawGrid(context: context, center: graphCenter, radius: graphRadius)

        // Draw data polygon
        drawDataPolygon(context: context, center: graphCenter, radius: graphRadius)
      }
      .frame(width: totalSize, height: totalSize)

      // Category labels (using SwiftUI for text rendering)
      if showLabels {
        categoryLabels
      }
    }
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

  // MARK: - Canvas Drawing

  private func drawGrid(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Concentric polygons
    for level in 1...levels {
      let scale = CGFloat(level) / CGFloat(levels)
      var gridPath = Path()

      for index in 0..<categories.count {
        let point = pointPosition(index: index, value: scale, center: center, radius: radius)
        if index == 0 {
          gridPath.move(to: point)
        } else {
          gridPath.addLine(to: point)
        }
      }
      gridPath.closeSubpath()

      context.stroke(gridPath, with: .color(AppColors.borderMuted), lineWidth: 1)
    }

    // Radial lines
    for index in 0..<categories.count {
      let endPoint = pointPosition(index: index, value: 1.0, center: center, radius: radius)
      var linePath = Path()
      linePath.move(to: center)
      linePath.addLine(to: endPoint)
      context.stroke(linePath, with: .color(AppColors.borderMuted), lineWidth: 0.5)
    }
  }

  private func drawDataPolygon(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    var dataPath = Path()

    for (index, category) in categories.enumerated() {
      let score = (scores[category] ?? 0) * animationProgress
      let point = pointPosition(index: index, value: max(score, 0.05), center: center, radius: radius)

      if index == 0 {
        dataPath.move(to: point)
      } else {
        dataPath.addLine(to: point)
      }
    }
    dataPath.closeSubpath()

    // Fill
    context.fill(
      dataPath,
      with: .linearGradient(
        Gradient(colors: [AppColors.accent.opacity(0.3), AppColors.accent.opacity(0.1)]),
        startPoint: CGPoint(x: center.x, y: center.y - radius),
        endPoint: CGPoint(x: center.x, y: center.y + radius)
      )
    )

    // Stroke
    context.stroke(dataPath, with: .color(AppColors.accent), lineWidth: 2)

    // Data points
    for (index, category) in categories.enumerated() {
      let score = (scores[category] ?? 0) * animationProgress
      let point = pointPosition(index: index, value: max(score, 0.05), center: center, radius: radius)

      var circlePath = Path()
      circlePath.addEllipse(in: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8))
      context.fill(circlePath, with: .color(AppColors.accent))
    }
  }

  // MARK: - Category Labels

  private var categoryLabels: some View {
    GeometryReader { geometry in
      let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
      let labelRadius = (size / 2) + 30

      ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
        let angle = angleForIndex(index) - .pi / 2
        let x = center.x + labelRadius * cos(angle)
        let y = center.y + labelRadius * sin(angle)

        VStack(spacing: 2) {
          Image(systemName: category.icon)
            .font(.caption2)
            .foregroundStyle(category.color)

          Text(category.rawValue)
            .font(.system(size: 8))
            .fontWeight(.medium)
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .frame(width: 60)
        .position(x: x, y: y)
      }
    }
  }

  // MARK: - Geometry Helpers

  private func pointPosition(index: Int, value: CGFloat, center: CGPoint, radius: CGFloat) -> CGPoint {
    let scaledRadius = radius * value
    let angle = angleForIndex(index) - .pi / 2 // Start from top

    return CGPoint(
      x: center.x + scaledRadius * cos(angle),
      y: center.y + scaledRadius * sin(angle)
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
    Canvas { context, canvasSize in
      let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
      let radius = (size / 2) - 2

      // Simple grid
      for scale in [0.5, 1.0] as [CGFloat] {
        var gridPath = Path()
        for index in 0..<categories.count {
          let point = pointPosition(index: index, value: scale, center: center, radius: radius)
          if index == 0 {
            gridPath.move(to: point)
          } else {
            gridPath.addLine(to: point)
          }
        }
        gridPath.closeSubpath()
        context.stroke(gridPath, with: .color(AppColors.borderMuted.opacity(0.5)), lineWidth: 0.5)
      }

      // Data polygon
      var dataPath = Path()
      for (index, category) in categories.enumerated() {
        let score = scores[category] ?? 0
        let point = pointPosition(index: index, value: max(score, 0.05), center: center, radius: radius)

        if index == 0 {
          dataPath.move(to: point)
        } else {
          dataPath.addLine(to: point)
        }
      }
      dataPath.closeSubpath()

      context.fill(dataPath, with: .color(AppColors.accent.opacity(0.3)))
      context.stroke(dataPath, with: .color(AppColors.accent), lineWidth: 1.5)
    }
    .frame(width: size, height: size)
  }

  private func pointPosition(index: Int, value: CGFloat, center: CGPoint, radius: CGFloat) -> CGPoint {
    let scaledRadius = radius * value
    let slice = (2 * .pi) / CGFloat(categories.count)
    let angle = slice * CGFloat(index) - .pi / 2

    return CGPoint(
      x: center.x + scaledRadius * cos(angle),
      y: center.y + scaledRadius * sin(angle)
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
