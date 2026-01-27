//
//  Haptics.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

enum AppHaptics {
  
  // MARK: - Calendar Feedback Types
  
  enum Calendar {
    case selectToday
    case selectDay
    case selectCompletedDay
    case selectFutureDay
    case returnToToday
    
    var feedback: SensoryFeedback {
      switch self {
      case .selectToday:
        return .success
      case .selectDay:
        return .selection
      case .selectCompletedDay:
        return .impact(weight: .medium)
      case .selectFutureDay:
        return .warning
      case .returnToToday:
        return .impact(weight: .heavy, intensity: 0.8)
      }
    }
  }
}
