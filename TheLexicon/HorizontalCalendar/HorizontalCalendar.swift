//
//  HorizontalCalendar.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

struct HorizontalCalendar: View {

  @Environment(\.scenePhase) private var scenePhase

  let screenSize: CGSize
  @Binding var selectedDate: Date

  @State private var vm = HorizontalCalendarViewModel()
  @State private var scrollProxy: ScrollViewProxy?

  private var showChevron: Bool {
    return vm.daysDifferenceFromToday(selectedDate) >= 5
  }
  
  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: AppLayout.Spacing.sm(screenSize)) {
          ForEach(vm.dates, id: \.self) { date in
            CalendarDayButton(
              date: date,
              isSelected: vm.calendar.isDate(date, inSameDayAs: selectedDate),
              completedCount: vm.completedCount(for: date),
              totalCount: vm.totalCount(for: date),
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
    .sensoryFeedback(.selection, trigger: selectedDate)
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase == .active {
        vm.refreshIfNeeded()
      }
    }
  }
  
  // MARK: - Actions

  private func selectDate(_ date: Date) {
    guard !vm.isFuture(date) else { return }
    selectedDate = date

    withAnimation(.snappy) {
      scrollProxy?.scrollTo(date, anchor: .center)
    }
  }

  private func scrollToToday() {
    selectedDate = vm.today

    withAnimation(.snappy) {
      scrollProxy?.scrollTo(vm.today, anchor: .center)
    }
  }
}

#Preview {
  MainView()
    .withPreviewContainer()
}
