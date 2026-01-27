//
//  TodayChevronButton.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//


import SwiftUI

struct TodayChevronButton: View {
  
  let direction: String
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Image(systemName: direction)
        .font(.caption)
        .fontWeight(.semibold)
        .fontDesign(.serif)
        .foregroundStyle(AppColors.textInverse)
        .padding()
    }
    .background {
      Circle()
        .glassEffect(.clear.tint(AppColors.accentMuted))
    }
    .transition(.opacity.combined(with: .scale))
    .padding(.horizontal)
  }
}


#Preview {
  TodayChevronButton(direction: "chevron.left") {
    //
  }
}
