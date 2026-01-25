//
//  AppLayout.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

enum AppLayout {
  
  // MARK: - Corner Radius
  
  enum CornerRadius {
    static func small(_ screen: CGSize) -> CGFloat { screen.width * 0.015 }
    static func medium(_ screen: CGSize) -> CGFloat { screen.width * 0.025 }
    static func large(_ screen: CGSize) -> CGFloat { screen.width * 0.04 }
    static func extraLarge(_ screen: CGSize) -> CGFloat { screen.width * 0.06 }
  }
  
  // MARK: - Stroke
  
  enum Stroke {
    static func thin(_ screen: CGSize) -> CGFloat { screen.width * 0.002 }
    static func regular(_ screen: CGSize) -> CGFloat { screen.width * 0.005 }
    static func thick(_ screen: CGSize) -> CGFloat { screen.width * 0.008 }
  }
  
  // MARK: - Spacing
  
  enum Spacing {
    static func xxs(_ screen: CGSize) -> CGFloat { screen.width * 0.01 }
    static func xs(_ screen: CGSize) -> CGFloat { screen.width * 0.02 }
    static func sm(_ screen: CGSize) -> CGFloat { screen.width * 0.03 }
    static func md(_ screen: CGSize) -> CGFloat { screen.width * 0.04 }
    static func lg(_ screen: CGSize) -> CGFloat { screen.width * 0.06 }
    static func xl(_ screen: CGSize) -> CGFloat { screen.width * 0.08 }
  }
  
  // MARK: - Padding
  
  enum Padding {
    static func xs(_ screen: CGSize) -> CGFloat { screen.width * 0.02 }
    static func sm(_ screen: CGSize) -> CGFloat { screen.width * 0.03 }
    static func md(_ screen: CGSize) -> CGFloat { screen.width * 0.04 }
    static func lg(_ screen: CGSize) -> CGFloat { screen.width * 0.06 }
    static func xl(_ screen: CGSize) -> CGFloat { screen.width * 0.08 }
  }
}

// MARK: - Calendar

extension AppLayout {
  
  enum Calendar {
    static func buttonWidth(_ screen: CGSize) -> CGFloat { screen.width * 0.18 }
    static func buttonHeight(_ screen: CGSize) -> CGFloat { screen.height * 0.14 }
    static func cornerRadius(_ screen: CGSize) -> CGFloat { AppLayout.CornerRadius.medium(screen) }
    static func strokeWidth(_ screen: CGSize) -> CGFloat { AppLayout.Stroke.regular(screen) }
    static func bottomElementHeight(_ screen: CGSize) -> CGFloat { screen.height * 0.02 }
  }
}
