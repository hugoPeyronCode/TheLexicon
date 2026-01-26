//
//  HorizontalCalendar.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 25/01/2026.
//

import SwiftUI

@Observable
class HorizontalCalendarViewModel {
  
  // MARK: - Properties
  
  let startDate: Date = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
  let futureDays: Int = 5
  
  var selectedDate: Date? = Calendar.current.startOfDay(for: Date())
  
  private let calendar = Calendar.current
  
  // MARK: - Computed Properties
  
  var dates: [Date] {
    var result: [Date] = []
    var current = startDate
    let today = calendar.startOfDay(for: Date())
    let endDate = calendar.date(byAdding: .day, value: futureDays, to: today)!
    
    while current <= endDate {
      result.append(current)
      current = calendar.date(byAdding: .day, value: 1, to: current)!
    }
    return result
  }
  
  var today: Date {
    calendar.startOfDay(for: Date())
  }
  
  // MARK: - Functions
  
  func isSelected(_ date: Date) -> Bool {
    guard let selectedDate else { return false }
    return calendar.isDate(date, inSameDayAs: selectedDate)
  }
  
  func isFuture(_ date: Date) -> Bool {
    date > today
  }
  
  func selectDate(_ date: Date) {
    guard !isFuture(date) else { return }
    selectedDate = date
  }
  
  func completedCount(for date: Date) -> Int {
    if calendar.isDateInToday(date) || isFuture(date) {
      return 0
    }
    let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
    return abs(daysAgo) % 5
  }
}

@Observable
class HorizontalCalendarScrollState {
  
  // MARK: - Properties
  
  var visibleDates: Set<Date> = []
  
  private let calendar = Calendar.current
  
  // MARK: - Computed Properties
  
  var today: Date {
    calendar.startOfDay(for: Date())
  }
  
  var isTodayVisible: Bool {
    visibleDates.contains { date in
      calendar.isDateInToday(date)
    }
  }
  
  var isTodayOnRight: Bool {
    guard let minVisible = visibleDates.min() else { return true }
    return today > minVisible
  }
  
  var chevronDirection: String {
    isTodayOnRight ? "chevron.right" : "chevron.left"
  }
  
  // MARK: - Functions
  
  func markVisible(_ date: Date) {
    visibleDates.insert(date)
  }
  
  func markHidden(_ date: Date) {
    visibleDates.remove(date)
  }
}

struct HorizontalCalendar: View {
  
  @State private var vm = HorizontalCalendarViewModel()
  @State private var scrollState = HorizontalCalendarScrollState()
  @State private var scrollProxy: ScrollViewProxy?
  
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
              selectAndScroll(to: date)
            }
            .onGeometryChange(for: Bool.self) { geo in
              let frame = geo.frame(in: .global)
              return frame.minX < screenSize.width && frame.maxX > 0
            } action: { isVisible in
              if isVisible {
                scrollState.markVisible(date)
              } else {
                scrollState.markHidden(date)
              }
            }
          }
        }
        .padding()
      }
      .overlay(alignment: .trailing) {
        if !scrollState.isTodayVisible {
          TodayChevronButton(direction: scrollState.chevronDirection) {
            scrollToToday()
          }
        }
      }
      .animation(.easeInOut(duration: 0.2), value: scrollState.isTodayVisible)
      .onAppear {
        scrollProxy = proxy
        scrollToToday()
      }
    }
  }
  
  // MARK: - Screen Size Helper
  
  private var screenSize: CGSize {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
      return UIScreen.main.bounds.size
    }
    return window.bounds.size
  }
  
  private func selectAndScroll(to date: Date) {
    vm.selectDate(date)
    guard vm.isSelected(date) else { return }
    
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

// MARK: - Subviews

struct TodayChevronButton: View {
  
  let direction: String
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Image(systemName: direction)
        .font(.caption)
        .fontWeight(.semibold)
        .fontDesign(.serif)
        .foregroundStyle(AppColors.textPrimary)
        .padding(10)
        .background {
          Circle()
            .glassEffect(.identity.tint(AppColors.accent))
            .foregroundStyle(AppColors.accentMuted)
        }
    }
    .padding(.horizontal)
    .padding(.top, 8)
    .transition(.opacity.combined(with: .scale))
  }
}

#Preview {
  MainView()
}
