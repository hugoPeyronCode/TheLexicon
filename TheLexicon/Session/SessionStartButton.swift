//
//  SessionStartButton.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

struct SessionStartButton: View {
  let isCompleted: Bool
  let action: () -> Void

  init(isCompleted: Bool = false, action: @escaping () -> Void) {
    self.isCompleted = isCompleted
    self.action = action
  }

  var body: some View {
    GlassEffectContainer {
      Button(action: action) {
        HStack(spacing: 6) {
          if isCompleted {
            Image(systemName: "checkmark.circle.fill")
          }
          Text(isCompleted ? "Completed!" : "Start Daily")
        }
        .fontDesign(.serif)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(isCompleted ? AppColors.stateSuccess : AppColors.textInverse)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
      }
      .tint(isCompleted ? AppColors.surfaceDefault : AppColors.accent)
      .buttonStyle(.glassProminent)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .disabled(isCompleted)
    }
  }
}

#Preview {
  VStack {
    Spacer()
    SessionStartButton {
      print("Session started!")
    }
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  .background(Color(.systemBackground))
}

struct GlassyButtonBar: View {
  @Namespace private var glassNS

  var body: some View {
    GlassEffectContainer {
      HStack {
        Button {
          // action
        } label: {
          Text("Start Session")
            .font(.headline)
            .fontWeight(.semibold)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
        .buttonStyle(.glassProminent)              // system glassy button
        .tint(.orange)                             // your accent
        .glassEffectID("primary-cta", in: glassNS)
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
  }
}

#Preview {
  VStack {
    Text("Bob")
      .padding()
      .glassEffect(
        .regular
          .tint(AppColors.accentMuted.opacity(0.9)) // more solid
          .interactive()                            // squishy, liquid feel
      )
    GlassyButtonBar()
  }
}
