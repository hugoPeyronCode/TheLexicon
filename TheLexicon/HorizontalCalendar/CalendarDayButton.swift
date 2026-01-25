//
//  CalendarDayButton.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

struct CalendarDayButton: View {
  
  let date: Date
  let isSelected: Bool
  let completedCount: Int
  let totalCount: Int
  let screenSize: CGSize
  
  // MARK: - Layout
  
  private var buttonWidth: CGFloat { screenSize.width * 0.18 }
  private var buttonHeight: CGFloat { screenSize.height * 0.14 }
  private var cornerRadius: CGFloat { screenSize.width * 0.025 }
  private var strokeWidth: CGFloat { screenSize.width * 0.005 }
  private var bottomElementHeight: CGFloat { screenSize.height * 0.02 }
  
  // MARK: - Fonts
  
  private var iconFont: Font { .system(size: screenSize.width * 0.06) }
  private var dayFont: Font { .system(size: screenSize.width * 0.04) }
  private var bottomFont: Font { .system(size: screenSize.width * 0.03) }
  
  // MARK: - Date Helpers
  
  private var isToday: Bool {
    Calendar.current.isDateInToday(date)
  }
  
  private var isFuture: Bool {
    date > Calendar.current.startOfDay(for: Date())
  }
  
  private var progress: CGFloat {
    guard totalCount > 0 else { return 0 }
    return CGFloat(completedCount) / CGFloat(totalCount)
  }
  
  private var isCompleted: Bool {
    completedCount >= totalCount && totalCount > 0
  }
  
  private var dayAbbreviation: String {
    date.formatted(.dateTime.weekday(.abbreviated))
  }
  
  private var dayNumber: String {
    date.formatted(.dateTime.day())
  }
  
  // MARK: - State-Based Styling
  
  private var sealIcon: String {
    if isFuture {
      return "seal"
    } else if isCompleted {
      return "checkmark.seal.fill"
    } else if completedCount > 0 {
      return "checkmark.seal"
    } else {
      return "seal"
    }
  }
  
  private var iconColor: Color {
    if isFuture {
      return AppColors.Calendar.iconFuture
    } else if isCompleted {
      return AppColors.Calendar.iconCompleted
    } else if completedCount > 0 {
      return AppColors.Calendar.iconPartial
    } else {
      return AppColors.Calendar.iconDefault
    }
  }
  
  private var backgroundColor: Color {
    if isSelected {
      return AppColors.Calendar.backgroundSelected
    } else if isToday {
      return AppColors.Calendar.backgroundToday
    } else if isFuture {
      return AppColors.Calendar.backgroundFuture
    } else if isCompleted {
      return AppColors.Calendar.backgroundCompleted
    } else {
      return AppColors.Calendar.backgroundDefault
    }
  }
  
  private var borderColor: Color {
    if isSelected {
      return AppColors.Calendar.borderSelected
    } else if isToday {
      return AppColors.Calendar.borderToday
    } else if isFuture {
      return AppColors.Calendar.borderFuture
    } else {
      return AppColors.Calendar.borderDefault
    }
  }
  
  private var borderWidth: CGFloat {
    isSelected || isToday ? 1.5 : 1
  }
  
  private var textColor: Color {
    isFuture ? AppColors.textMuted : AppColors.textPrimary
  }
  
  private var dayAbbreviationColor: Color {
    isFuture ? AppColors.textMuted : AppColors.textSecondary
  }
  
  private var progressColor: Color {
    isCompleted ? AppColors.Calendar.progressComplete : AppColors.Calendar.progressPartial
  }
  
  private var bottomTextColor: Color {
    isFuture ? AppColors.textFaint : AppColors.textSecondary
  }
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: sealIcon)
        .font(iconFont)
        .foregroundStyle(iconColor)
      
      Text(dayAbbreviation)
        .font(dayFont)
        .foregroundStyle(dayAbbreviationColor)
      
      Text(dayNumber)
        .font(dayFont)
        .fontWeight(isToday ? .semibold : .regular)
        .foregroundStyle(textColor)
      
      Group {
        if isToday {
          Image(systemName: "circle.fill")
            .font(bottomFont)
            .foregroundStyle(AppColors.Calendar.todayDot)
        } else {
          Text("\(completedCount)/\(totalCount)")
            .font(bottomFont)
            .foregroundStyle(bottomTextColor)
        }
      }
      .frame(height: bottomElementHeight)
    }
    .fontDesign(.serif)
    .frame(width: buttonWidth, height: buttonHeight)
    .background {
      RoundedRectangle(cornerRadius: cornerRadius)
        .fill(backgroundColor)
    }
    .overlay {
      RoundedRectangle(cornerRadius: cornerRadius)
        .stroke(lineWidth: borderWidth)
        .foregroundStyle(borderColor)
      
      if !isFuture && completedCount > 0 {
        ProgressRoundedRect(progress: progress, cornerRadius: cornerRadius)
          .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
          .foregroundStyle(progressColor)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: isSelected)
  }
}

// MARK: - Preview

#Preview("Light Mode") {
  GeometryReader { geometry in
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(-5..<6, id: \.self) { offset in
          let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
          CalendarDayButton(
            date: date,
            isSelected: offset == 0,
            completedCount: offset < 0 ? min(4, abs(offset)) : 0,
            totalCount: 4,
            screenSize: geometry.size
          )
        }
      }
      .padding()
    }
  }
  .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
  GeometryReader { geometry in
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(-5..<6, id: \.self) { offset in
          let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
          CalendarDayButton(
            date: date,
            isSelected: offset == 0,
            completedCount: offset < 0 ? min(4, abs(offset)) : 0,
            totalCount: 4,
            screenSize: geometry.size
          )
        }
      }
      .padding()
    }
  }
  .preferredColorScheme(.dark)
}
