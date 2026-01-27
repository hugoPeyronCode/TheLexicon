//
//  HorizontalCalendar.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

struct HorizontalCalendar: View {
  
  let screenSize: CGSize
  
  @State private var vm = HorizontalCalendarViewModel()
  @State private var scrollProxy: ScrollViewProxy?
  
  private var showChevron: Bool {
    guard let selected = vm.selectedDate else { return false }
    return vm.daysDifferenceFromToday(selected) >= 5
  }
  
  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: AppLayout.Spacing.sm(screenSize)) {
          ForEach(vm.dates, id: \.self) { date in
            CalendarDayButton(
              date: date,
              isSelected: vm.isSelected(date),
              completedCount: vm.completedCount(for: date),
              totalCount: 4,
              screenSize: screenSize
            )
            .id(date)
            .onTapGesture {
              selectDate(date)
            }
          }
        }
        .padding()
      }
      .overlay(alignment: .trailing) {
        if showChevron {
          TodayChevronButton(direction: "chevron.right") {
            scrollToToday()
          }
        }
      }
      .animation(.easeInOut(duration: 0.2), value: showChevron)
      .task {
          scrollProxy = proxy
          try? await Task.sleep(for: .milliseconds(50))
          scrollProxy?.scrollTo(vm.today, anchor: .center)
      }
    }
    .sensoryFeedback(.selection, trigger: vm.selectedDate)
  }
  
  // MARK: - Actions
  
  private func selectDate(_ date: Date) {
    vm.selectDate(date)
    
    withAnimation(.snappy) {
      scrollProxy?.scrollTo(date, anchor: .center)
    }
  }
  
  private func scrollToToday() {
    vm.selectDate(vm.today)
    
    withAnimation(.snappy) {
      scrollProxy?.scrollTo(vm.today, anchor: .center)
    }
  }
}

#Preview {
  MainView()
}
