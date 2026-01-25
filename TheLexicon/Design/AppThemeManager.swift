//
//  AppThemeManager.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

@Observable
class AppThemeManager {
  static let shared = AppThemeManager()
  
  var colorTheme: AppColorTheme {
    get { AppColorManager.shared.currentTheme }
    set { AppColorManager.shared.currentTheme = newValue }
  }
  
  var fontDesign: AppFontDesign {
    get { AppFontManager.shared.currentDesign }
    set { AppFontManager.shared.currentDesign = newValue }
  }
  
  private init() {}
  
  // MARK: - Presets
  
  func applyClassicTheme() {
    colorTheme = .terracotta
    fontDesign = .serif
  }
  
  func applyModernTheme() {
    colorTheme = .ocean
    fontDesign = .rounded
  }
  
  func applyMinimalTheme() {
    colorTheme = .charcoal
    fontDesign = .system
  }
  
  func applyCodeTheme() {
    colorTheme = .forest
    fontDesign = .monospaced
  }
}
