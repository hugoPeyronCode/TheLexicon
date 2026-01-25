//
//  AppColors.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

// MARK: - Color Theme

enum AppColorTheme: String, CaseIterable {
  case terracotta
  case ocean
  case forest
  case lavender
  case charcoal
  
  var accent: Color {
    switch self {
    case .terracotta: return Color(red: 0.85, green: 0.45, blue: 0.35)
    case .ocean: return Color(red: 0.25, green: 0.55, blue: 0.75)
    case .forest: return Color(red: 0.35, green: 0.65, blue: 0.45)
    case .lavender: return Color(red: 0.65, green: 0.50, blue: 0.75)
    case .charcoal: return Color(red: 0.40, green: 0.40, blue: 0.45)
    }
  }
  
  var displayName: String {
    rawValue.capitalized
  }
}

// MARK: - Color Manager

@Observable
class AppColorManager {
  static let shared = AppColorManager()
  
  var currentTheme: AppColorTheme = .terracotta
  
  private init() {}
}

// MARK: - App Colors

enum AppColors {
  
  // MARK: - Brand
  
  static var accent: Color {
    AppColorManager.shared.currentTheme.accent
  }
  
  static var accentMuted: Color { accent.opacity(0.7) }
  static var accentSubtle: Color { accent.opacity(0.15) }
  static var accentFaint: Color { accent.opacity(0.05) }
  
  // MARK: - Text
  
  static let textPrimary = Color.primary
  static let textSecondary = Color.secondary
  static let textMuted = Color.secondary.opacity(0.5)
  static let textFaint = Color.secondary.opacity(0.3)
  static let textInverse = Color.white
  
  // MARK: - Background
  
  static let backgroundPrimary = Color(.systemBackground)
  static let backgroundSecondary = Color(.secondarySystemBackground)
  static let backgroundTertiary = Color(.tertiarySystemBackground)
  static let backgroundElevated = Color(.systemBackground)
  static let backgroundGrouped = Color(.systemGroupedBackground)
  
  // MARK: - Surface
  
  static let surfaceDefault = Color.primary.opacity(0.03)
  static let surfaceHover = Color.primary.opacity(0.05)
  static let surfaceActive = Color.primary.opacity(0.08)
  static var surfaceSelected: Color { accentSubtle }
  static let surfaceDisabled = Color.secondary.opacity(0.1)
  
  // MARK: - Border
  
  static let borderDefault = Color.secondary.opacity(0.2)
  static let borderStrong = Color.primary.opacity(0.3)
  static let borderMuted = Color.secondary.opacity(0.15)
  static var borderAccent: Color { accent.opacity(0.5) }
  
  // MARK: - State
  
  static let stateSuccess = Color.green
  static let stateSuccessSubtle = Color.green.opacity(0.15)
  static let stateWarning = Color.orange
  static let stateWarningSubtle = Color.orange.opacity(0.15)
  static let stateError = Color.red
  static let stateErrorSubtle = Color.red.opacity(0.15)
  static let stateInfo = Color.blue
  static let stateInfoSubtle = Color.blue.opacity(0.15)
  
  // MARK: - Interactive
  
  static var buttonPrimary: Color { accent }
  static let buttonPrimaryText = Color.white
  static let buttonSecondary = Color.primary.opacity(0.1)
  static let buttonSecondaryText = textPrimary
  static let buttonDisabled = Color.secondary.opacity(0.3)
  static let buttonDisabledText = textMuted
  
  // MARK: - Icon
  
  static let iconPrimary = Color.primary
  static let iconSecondary = Color.secondary
  static let iconMuted = Color.secondary.opacity(0.5)
  static var iconAccent: Color { accent }
  static let iconDisabled = Color.secondary.opacity(0.4)
  
  // MARK: - Progress
  
  static let progressTrack = Color.secondary.opacity(0.2)
  static var progressFill: Color { accent }
  static var progressFillMuted: Color { accentMuted }
  
  // MARK: - Divider
  
  static let divider = Color.secondary.opacity(0.2)
  static let dividerStrong = Color.secondary.opacity(0.4)
  
  // MARK: - Shadow
  
  static let shadow = Color.black.opacity(0.1)
  static let shadowStrong = Color.black.opacity(0.2)
}

// MARK: - Calendar

extension AppColors {
  
  enum Calendar {
    static var backgroundSelected: Color { AppColors.surfaceSelected }
    static let backgroundToday = AppColors.surfaceHover
    static var backgroundCompleted: Color { AppColors.accentFaint }
    static let backgroundDefault = AppColors.surfaceDefault
    static let backgroundFuture = Color.clear
    
    static var borderSelected: Color { AppColors.borderAccent }
    static let borderToday = AppColors.borderStrong
    static let borderDefault = AppColors.borderDefault
    static let borderFuture = AppColors.borderMuted
    
    static var iconCompleted: Color { AppColors.accent }
    static var iconPartial: Color { AppColors.accentMuted }
    static let iconDefault = AppColors.iconSecondary
    static let iconFuture = AppColors.iconDisabled
    
    static var progressComplete: Color { AppColors.progressFill }
    static var progressPartial: Color { AppColors.progressFillMuted }
    
    static var todayDot: Color { AppColors.accent }
  }
}

// MARK: - Theme Preview

#Preview("Theme Switcher") {
  ThemePreviewView()
}

#Preview("Color Palette") {
  ColorPalettePreviewView()
}

#Preview("Dark Mode") {
  ColorPalettePreviewView()
    .preferredColorScheme(.dark)
}

// MARK: - Preview Views

private struct ThemePreviewView: View {
  @State private var selectedTheme: AppColorTheme = .terracotta
  
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        
        // Theme Picker
        VStack(alignment: .leading, spacing: 12) {
          Text("Select Theme")
            .font(.headline)
            .fontDesign(.serif)
          
          HStack(spacing: 12) {
            ForEach(AppColorTheme.allCases, id: \.self) { theme in
              ThemeButton(
                theme: theme,
                isSelected: selectedTheme == theme
              ) {
                selectedTheme = theme
                AppColorManager.shared.currentTheme = theme
              }
            }
          }
        }
        
        Divider()
        
        // Preview Components
        VStack(alignment: .leading, spacing: 16) {
          Text("Preview")
            .font(.headline)
            .fontDesign(.serif)
          
          // Buttons
          HStack(spacing: 12) {
            Button("Primary") {}
              .buttonStyle(.borderedProminent)
              .tint(AppColors.accent)
            
            Button("Secondary") {}
              .buttonStyle(.bordered)
              .tint(AppColors.accent)
          }
          
          // Progress
          VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
              .font(.subheadline)
              .foregroundStyle(AppColors.textSecondary)
            
            ProgressView(value: 0.6)
              .tint(AppColors.accent)
          }
          
          // Cards
          HStack(spacing: 12) {
            PreviewCard(title: "Default", background: AppColors.surfaceDefault, border: AppColors.borderDefault)
            PreviewCard(title: "Selected", background: AppColors.surfaceSelected, border: AppColors.borderAccent)
            PreviewCard(title: "Active", background: AppColors.surfaceActive, border: AppColors.borderStrong)
          }
          
          // Icons
          HStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
              .foregroundStyle(AppColors.accent)
            Image(systemName: "checkmark.seal")
              .foregroundStyle(AppColors.accentMuted)
            Image(systemName: "seal")
              .foregroundStyle(AppColors.iconSecondary)
            Image(systemName: "seal")
              .foregroundStyle(AppColors.iconDisabled)
          }
          .font(.title)
        }
        
        Divider()
        
        // Accent Variations
        VStack(alignment: .leading, spacing: 12) {
          Text("Accent Variations")
            .font(.headline)
            .fontDesign(.serif)
          
          HStack(spacing: 12) {
            ColorSwatch(name: "accent", color: AppColors.accent)
            ColorSwatch(name: "muted", color: AppColors.accentMuted)
            ColorSwatch(name: "subtle", color: AppColors.accentSubtle)
            ColorSwatch(name: "faint", color: AppColors.accentFaint)
          }
        }
      }
      .padding()
    }
  }
}

private struct ThemeButton: View {
  let theme: AppColorTheme
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 6) {
        Circle()
          .fill(theme.accent)
          .frame(width: 40, height: 40)
          .overlay {
            Circle()
              .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2)
              .padding(-4)
          }
        
        Text(theme.displayName)
          .font(.caption2)
          .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
      }
    }
    .buttonStyle(.plain)
  }
}

private struct PreviewCard: View {
  let title: String
  let background: Color
  let border: Color
  
  var body: some View {
    VStack {
      Text(title)
        .font(.caption)
        .foregroundStyle(AppColors.textSecondary)
    }
    .frame(width: 80, height: 60)
    .background {
      RoundedRectangle(cornerRadius: 8)
        .fill(background)
    }
    .overlay {
      RoundedRectangle(cornerRadius: 8)
        .stroke(border, lineWidth: 1)
    }
  }
}

private struct ColorPalettePreviewView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        
        ColorSection(title: "Brand") {
          ColorSwatch(name: "accent", color: AppColors.accent)
          ColorSwatch(name: "accentMuted", color: AppColors.accentMuted)
          ColorSwatch(name: "accentSubtle", color: AppColors.accentSubtle)
          ColorSwatch(name: "accentFaint", color: AppColors.accentFaint)
        }
        
        ColorSection(title: "Text") {
          ColorSwatch(name: "textPrimary", color: AppColors.textPrimary)
          ColorSwatch(name: "textSecondary", color: AppColors.textSecondary)
          ColorSwatch(name: "textMuted", color: AppColors.textMuted)
          ColorSwatch(name: "textFaint", color: AppColors.textFaint)
        }
        
        ColorSection(title: "Surface") {
          ColorSwatch(name: "surfaceDefault", color: AppColors.surfaceDefault)
          ColorSwatch(name: "surfaceHover", color: AppColors.surfaceHover)
          ColorSwatch(name: "surfaceActive", color: AppColors.surfaceActive)
          ColorSwatch(name: "surfaceSelected", color: AppColors.surfaceSelected)
        }
        
        ColorSection(title: "Border") {
          ColorSwatch(name: "borderDefault", color: AppColors.borderDefault)
          ColorSwatch(name: "borderStrong", color: AppColors.borderStrong)
          ColorSwatch(name: "borderMuted", color: AppColors.borderMuted)
          ColorSwatch(name: "borderAccent", color: AppColors.borderAccent)
        }
        
        ColorSection(title: "State") {
          ColorSwatch(name: "stateSuccess", color: AppColors.stateSuccess)
          ColorSwatch(name: "stateWarning", color: AppColors.stateWarning)
          ColorSwatch(name: "stateError", color: AppColors.stateError)
          ColorSwatch(name: "stateInfo", color: AppColors.stateInfo)
        }
        
        ColorSection(title: "Buttons") {
          ColorSwatch(name: "buttonPrimary", color: AppColors.buttonPrimary)
          ColorSwatch(name: "buttonSecondary", color: AppColors.buttonSecondary)
          ColorSwatch(name: "buttonDisabled", color: AppColors.buttonDisabled)
        }
      }
      .padding()
    }
  }
}

// MARK: - Preview Helpers

private struct ColorSection<Content: View>: View {
  let title: String
  @ViewBuilder let content: Content
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.headline)
        .fontDesign(.serif)
      
      HStack(spacing: 12) {
        content
      }
    }
  }
}

private struct ColorSwatch: View {
  let name: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 4) {
      RoundedRectangle(cornerRadius: 8)
        .fill(color)
        .frame(width: 60, height: 60)
        .overlay {
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        }
      
      Text(name)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .frame(width: 70)
  }
}
