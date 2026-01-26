//
//  MainView.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 26/01/2026.
//

import SwiftUI

struct MainView: View {
  var body: some View {
    GeometryReader { geometry in
      VStack {
        HorizontalCalendar()
          .frame(height: geometry.size.height * 0.18)
        Spacer()
      }
    }
  }
}

#Preview {
  MainView()
}
