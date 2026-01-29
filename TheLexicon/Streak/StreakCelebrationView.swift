//
//  StreakCelebrationView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import SwiftUI

struct StreakCelebrationView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  let streakCount: Int
  let longestStreak: Int
  let isNewStreak: Bool // True when just completed today's game

  // Animation states
  @State private var flameScale: CGFloat = 0.3
  @State private var flameOpacity: CGFloat = 0
  @State private var numberScale: CGFloat = 0.5
  @State private var numberOpacity: CGFloat = 0
  @State private var textOpacity: CGFloat = 0
  @State private var particlesVisible: Bool = false
  @State private var glowPulse: Bool = false
  @State private var statsOpacity: CGFloat = 0
  @State private var buttonOpacity: CGFloat = 0

  // Haptic triggers
  @State private var flameHapticTrigger: Bool = false
  @State private var numberHapticTrigger: Bool = false

  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  private var backgroundColor: Color {
    isDarkMode ? Color.black.opacity(0.95) : AppColors.backgroundPrimary
  }

  private var textPrimaryColor: Color {
    isDarkMode ? Color.white : AppColors.textPrimary
  }

  private var textSecondaryColor: Color {
    isDarkMode ? Color.white.opacity(0.6) : AppColors.textSecondary
  }

  private var cardBackgroundColor: Color {
    isDarkMode ? Color.white.opacity(0.1) : AppColors.surfaceDefault
  }

  var body: some View {
    ZStack {
      // Background
      backgroundColor
        .ignoresSafeArea()

      // Particles
      if particlesVisible {
        ParticleEmitterView()
          .allowsHitTesting(false)
      }

      VStack(spacing: 40) {
        Spacer()

        // Flame with glow
        ZStack {
          // Glow effect
          Circle()
            .fill(
              RadialGradient(
                colors: [
                  AppColors.accent.opacity(isDarkMode ? 0.6 : 0.4),
                  AppColors.accent.opacity(isDarkMode ? 0.3 : 0.2),
                  Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: glowPulse ? 140 : 120
              )
            )
            .frame(width: 280, height: 280)
            .scaleEffect(flameScale)

          // Main flame icon
          Image(systemName: "flame.fill")
            .font(.system(size: 120))
            .foregroundStyle(
              LinearGradient(
                colors: [
                  Color.yellow,
                  AppColors.accent,
                  Color.red
                ],
                startPoint: .top,
                endPoint: .bottom
              )
            )
            .shadow(color: AppColors.accent.opacity(isDarkMode ? 0.8 : 0.5), radius: 20)
            .scaleEffect(flameScale)
            .opacity(flameOpacity)
        }

        // Streak number
        VStack(spacing: 8) {
          Text("\(streakCount)")
            .font(.system(size: 80, weight: .black, design: .rounded))
            .foregroundStyle(
              LinearGradient(
                colors: isDarkMode
                  ? [Color.white, Color.white.opacity(0.8)]
                  : [AppColors.accent, AppColors.accent.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
              )
            )
            .shadow(color: AppColors.accent.opacity(isDarkMode ? 0.5 : 0.3), radius: 10)
            .scaleEffect(numberScale)
            .opacity(numberOpacity)
            .contentTransition(.numericText())

          Text(streakCount == 1 ? "Day Streak!" : "Day Streak!")
            .font(.title2)
            .fontWeight(.bold)
            .fontDesign(.serif)
            .foregroundStyle(textPrimaryColor.opacity(0.9))
            .opacity(textOpacity)

          if isNewStreak {
            Text("You're on fire!")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundStyle(AppColors.accent)
              .opacity(textOpacity)
          }
        }

        // Stats
        HStack(spacing: 40) {
          StatItem(
            title: "Current",
            value: "\(streakCount)",
            icon: "flame",
            textColor: textPrimaryColor,
            secondaryColor: textSecondaryColor,
            backgroundColor: cardBackgroundColor
          )

          StatItem(
            title: "Longest",
            value: "\(longestStreak)",
            icon: "trophy",
            textColor: textPrimaryColor,
            secondaryColor: textSecondaryColor,
            backgroundColor: cardBackgroundColor
          )
        }
        .opacity(statsOpacity)

        Spacer()

        // Continue button
        Button {
          dismiss()
        } label: {
          Text("Continue")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
              RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.accent)
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
        .opacity(buttonOpacity)
      }
    }
    .onAppear {
      startAnimations()
    }
    // Haptic feedback
    .sensoryFeedback(.impact(weight: .heavy), trigger: flameHapticTrigger)
    .sensoryFeedback(.success, trigger: numberHapticTrigger)
    .sensoryFeedback(.impact(weight: .light), trigger: particlesVisible)
  }

  private func startAnimations() {
    // Flame entrance with haptic
    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
      flameScale = 1.0
      flameOpacity = 1.0
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      flameHapticTrigger.toggle()
    }

    // Number entrance with haptic (slightly delayed)
    withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
      numberScale = 1.0
      numberOpacity = 1.0
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
      numberHapticTrigger.toggle()
    }

    // Text fade in
    withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
      textOpacity = 1.0
    }

    // Particles burst
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      particlesVisible = true
    }

    // Glow pulse animation
    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
      glowPulse = true
    }

    // Stats fade in
    withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
      statsOpacity = 1.0
    }

    // Button fade in
    withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
      buttonOpacity = 1.0
    }
  }
}

// MARK: - Stat Item

private struct StatItem: View {
  let title: String
  let value: String
  let icon: String
  let textColor: Color
  let secondaryColor: Color
  let backgroundColor: Color

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundStyle(AppColors.accent)

      Text(value)
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(textColor)
        .contentTransition(.numericText())

      Text(title)
        .font(.caption)
        .foregroundStyle(secondaryColor)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background {
      RoundedRectangle(cornerRadius: 16)
        .fill(backgroundColor)
    }
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .stroke(AppColors.borderMuted, lineWidth: 1)
    }
  }
}

// MARK: - Particle Emitter

private struct ParticleEmitterView: View {
  @State private var particles: [Particle] = []

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ForEach(particles) { particle in
          ParticleView(particle: particle)
        }
      }
      .onAppear {
        createParticles(in: geometry.size)
      }
    }
  }

  private func createParticles(in size: CGSize) {
    let centerX = size.width / 2
    let centerY = size.height / 2 - 50 // Slightly above center (near flame)

    for i in 0..<30 {
      let angle = Double.random(in: 0...(2 * .pi))
      let speed = Double.random(in: 100...300)
      let delay = Double(i) * 0.02

      let particle = Particle(
        id: i,
        x: centerX,
        y: centerY,
        velocityX: cos(angle) * speed,
        velocityY: sin(angle) * speed - 100, // Bias upward
        scale: CGFloat.random(in: 0.3...1.0),
        opacity: 1.0,
        color: [Color.yellow, AppColors.accent, Color.orange, Color.red].randomElement()!,
        delay: delay
      )
      particles.append(particle)
    }
  }
}

private struct Particle: Identifiable {
  let id: Int
  var x: CGFloat
  var y: CGFloat
  let velocityX: Double
  let velocityY: Double
  let scale: CGFloat
  var opacity: Double
  let color: Color
  let delay: Double
}

private struct ParticleView: View {
  let particle: Particle

  @State private var offsetX: CGFloat = 0
  @State private var offsetY: CGFloat = 0
  @State private var opacity: Double = 1.0
  @State private var scale: CGFloat = 1.0

  var body: some View {
    Circle()
      .fill(particle.color)
      .frame(width: 8 * particle.scale, height: 8 * particle.scale)
      .position(x: particle.x + offsetX, y: particle.y + offsetY)
      .opacity(opacity)
      .scaleEffect(scale)
      .onAppear {
        withAnimation(.easeOut(duration: 1.5).delay(particle.delay)) {
          offsetX = particle.velocityX * 1.5
          offsetY = particle.velocityY * 1.5
          opacity = 0
          scale = 0.3
        }
      }
  }
}

// MARK: - Preview

#Preview("New Streak - Light") {
  StreakCelebrationView(
    streakCount: 7,
    longestStreak: 14,
    isNewStreak: true
  )
  .preferredColorScheme(.light)
}

#Preview("New Streak - Dark") {
  StreakCelebrationView(
    streakCount: 7,
    longestStreak: 14,
    isNewStreak: true
  )
  .preferredColorScheme(.dark)
}

#Preview("Viewing Streak - Light") {
  StreakCelebrationView(
    streakCount: 3,
    longestStreak: 10,
    isNewStreak: false
  )
  .preferredColorScheme(.light)
}

#Preview("First Day") {
  StreakCelebrationView(
    streakCount: 1,
    longestStreak: 1,
    isNewStreak: true
  )
}
