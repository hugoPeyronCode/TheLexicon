//
//  ProgressStroke.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

struct ProgressRoundedRect: Shape {
  var progress: CGFloat
  let cornerRadius: CGFloat
  
  var animatableData: CGFloat {
    get { progress }
    set { progress = newValue }
  }
  
  func path(in rect: CGRect) -> Path {
    let fullPath = RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    return fullPath.trimmedPath(from: 0, to: progress)
  }
}

extension Path {
  var length: CGFloat {
    var length: CGFloat = 0
    var previousPoint: CGPoint?
    
    forEach { element in
      switch element {
      case .move(to: let point):
        previousPoint = point
      case .line(to: let point):
        if let previous = previousPoint {
          length += hypot(point.x - previous.x, point.y - previous.y)
        }
        previousPoint = point
      case .quadCurve(to: let point, control: _):
        if let previous = previousPoint {
          length += hypot(point.x - previous.x, point.y - previous.y)
        }
        previousPoint = point
      case .curve(to: let point, control1: _, control2: _):
        if let previous = previousPoint {
          length += hypot(point.x - previous.x, point.y - previous.y)
        }
        previousPoint = point
      case .closeSubpath:
        break
      }
    }
    return length
  }
}

// MARK: - View Modifier

struct ProgressStrokeModifier: ViewModifier {
  let progress: CGFloat
  let cornerRadius: CGFloat
  let lineWidth: CGFloat
  let strokeColor: Color
  let trackColor: Color
  
  func body(content: Content) -> some View {
    content
      .overlay {
        // Track stroke
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(lineWidth: lineWidth / 2)
          .foregroundStyle(trackColor)
        
        // Progress stroke
        ProgressRoundedRect(progress: progress, cornerRadius: cornerRadius)
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
          .foregroundStyle(strokeColor)
      }
  }
}

extension View {
  func progressStroke(
    progress: CGFloat,
    cornerRadius: CGFloat,
    lineWidth: CGFloat = 2,
    strokeColor: Color = .brown,
    trackColor: Color = .gray.opacity(0.3)
  ) -> some View {
    modifier(ProgressStrokeModifier(
      progress: progress,
      cornerRadius: cornerRadius,
      lineWidth: lineWidth,
      strokeColor: strokeColor,
      trackColor: trackColor
    ))
  }
}

// MARK: - Preview

#Preview("Modifier Usage") {
  VStack(spacing: 20) {
    Text("25%")
      .padding(40)
      .background(RoundedRectangle(cornerRadius: 12).fill(.gray.opacity(0.1)))
      .progressStroke(progress: 0.25, cornerRadius: 12)
    
    Text("50%")
      .padding(40)
      .background(RoundedRectangle(cornerRadius: 12).fill(.gray.opacity(0.1)))
      .progressStroke(progress: 0.5, cornerRadius: 12, strokeColor: .blue)
    
    Text("75%")
      .padding(40)
      .background(RoundedRectangle(cornerRadius: 20).fill(.gray.opacity(0.1)))
      .progressStroke(progress: 0.75, cornerRadius: 20, lineWidth: 4, strokeColor: .green)
    
    Text("100%")
      .padding(40)
      .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.1)))
      .progressStroke(progress: 1.0, cornerRadius: 8, strokeColor: .orange)
  }
}
