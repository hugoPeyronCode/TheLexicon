//
//  MainView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 26/01/2026.
//

import SwiftUI

struct MainView: View {
  
  @State private var streakCount: Int = 7
  
  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        ScrollView() {
          HorizontalCalendar(screenSize: geometry.size)
          
          
          VStack{
            
          }
          
          VStack {
            SessionStartButton {
              //
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          StreakBadge(count: streakCount)
        }
        
        ToolbarItem(placement: .principal) {
          Text("The Lexicon")
            .fontWeight(.black)
            .font(.custom("NewYork-Bold", size: 25))
            .fontDesign(.serif)
            .foregroundStyle(AppColors.accentMuted)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            // Settings action
          } label: {
            Image(systemName: "gearshape")
          }
        }
      }
    }
  }
}

struct StreakBadge: View {
  let count: Int
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "flame.fill")
        .foregroundStyle(AppColors.accent)
      Text("\(count)")
        .fontWeight(.semibold)
    }
    .font(.subheadline)
  }
}

#Preview {
  MainView()
}
