//
//  AppFonts.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

// MARK: - Font Design

enum AppFontDesign {
  case serif
  case rounded
  case monospaced
  case system
  
  var swiftUIDesign: Font.Design {
    switch self {
    case .serif: return .serif
    case .rounded: return .rounded
    case .monospaced: return .monospaced
    case .system: return .default
    }
  }
}

// MARK: - Font Manager

@Observable
class AppFontManager {
  /// Shared instance for static AppFonts access.
  /// This is configured by AppDependencies at app startup.
  static var current: AppFontManager = AppFontManager()

  var currentDesign: AppFontDesign = .serif

  init() {}
}

// MARK: - App Fonts

enum AppFonts {
  
  // MARK: - Current Design
  
  static var design: Font.Design {
    AppFontManager.current.currentDesign.swiftUIDesign
  }
  
  // MARK: - Size
  
  enum Size {
    static func caption2(_ screen: CGSize) -> CGFloat { screen.width * 0.025 }
    static func caption(_ screen: CGSize) -> CGFloat { screen.width * 0.03 }
    static func footnote(_ screen: CGSize) -> CGFloat { screen.width * 0.035 }
    static func body(_ screen: CGSize) -> CGFloat { screen.width * 0.04 }
    static func title3(_ screen: CGSize) -> CGFloat { screen.width * 0.05 }
    static func title2(_ screen: CGSize) -> CGFloat { screen.width * 0.06 }
    static func title(_ screen: CGSize) -> CGFloat { screen.width * 0.07 }
    static func largeTitle(_ screen: CGSize) -> CGFloat { screen.width * 0.085 }
  }
  
  // MARK: - Font Builders
  
  static func caption2(_ screen: CGSize) -> Font {
    .system(size: Size.caption2(screen), design: design)
  }
  
  static func caption(_ screen: CGSize) -> Font {
    .system(size: Size.caption(screen), design: design)
  }
  
  static func footnote(_ screen: CGSize) -> Font {
    .system(size: Size.footnote(screen), design: design)
  }
  
  static func body(_ screen: CGSize) -> Font {
    .system(size: Size.body(screen), design: design)
  }
  
  static func title3(_ screen: CGSize) -> Font {
    .system(size: Size.title3(screen), design: design)
  }
  
  static func title2(_ screen: CGSize) -> Font {
    .system(size: Size.title2(screen), design: design)
  }
  
  static func title(_ screen: CGSize) -> Font {
    .system(size: Size.title(screen), design: design)
  }
  
  static func largeTitle(_ screen: CGSize) -> Font {
    .system(size: Size.largeTitle(screen), design: design)
  }
}

// MARK: - Calendar

extension AppFonts {
  
  enum Calendar {
    static func icon(_ screen: CGSize) -> Font { AppFonts.title2(screen) }
    static func day(_ screen: CGSize) -> Font { AppFonts.body(screen) }
    static func bottom(_ screen: CGSize) -> Font { AppFonts.caption(screen) }
  }
}
