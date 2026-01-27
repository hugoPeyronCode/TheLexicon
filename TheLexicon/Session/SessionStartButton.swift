//
//  SessionStartButton.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

struct SessionStartButton: View {
  let action: () -> Void
  
  var body: some View {
    GlassEffectContainer {
      Button(action: action) {
        Text("Start Session")
          .fontDesign(.serif)
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundStyle(AppColors.textInverse)
          .frame(maxWidth: .infinity)
          .padding()
      }
      .tint(AppColors.accent)
      .buttonStyle(.glassProminent)
      .padding()
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
