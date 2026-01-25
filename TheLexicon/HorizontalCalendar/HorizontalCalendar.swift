//
//  HorizontalCalendar.swift
//  TheLexicon
//
//Created by Hugo Peyron on 25/01/2026.
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
    
    // Compares two dates to check if they fall on the same calendar day.
    // This ignores time components (hours, minutes, seconds).
    // Example: Jan 25 at 10:00 AM and Jan 25 at 3:00 PM → returns true
    // Example: Jan 25 at 10:00 AM and Jan 26 at 10:00 AM → returns false
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
    // If it's today or a future date, no completed tasks
    if calendar.isDateInToday(date) || isFuture(date) {
      return 0
    }
    
    // PLACEHOLDER: This is fake data for demonstration.
    // It calculates how many days ago this date was,
    // then uses modulo 5 to get a number between 0-4.
    //
    // Example: 3 days ago → 3 % 5 = 3 completed
    // Example: 7 days ago → 7 % 5 = 2 completed
    //
    // TODO: Replace with real data from your levels/tasks model
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
    let result = visibleDates.contains { date in
      calendar.isDateInToday(date)
    }
    
    // Make it only working for day inthe past. Do not show the chevron when we are in the future.
    print("📅 Visible dates count: \(visibleDates.count)")
    print("📅 Today: \(today)")
    print("📅 Is today visible: \(result)")
    return result
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
    GeometryReader { geometry in
      let screenSize = geometry.size
      
      ScrollViewReader { proxy in
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 8) {
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
                vm.selectDate(date)
              }
              .onGeometryChange(for: Bool.self) { geo in
                let frame = geo.frame(in: .global)
                let screenWidth = screenSize.width
                return frame.minX < screenWidth && frame.maxX > 0
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
  }
  
  private func scrollToToday() {
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
        .foregroundStyle(.brown)
        .padding(10)
        .background {
          Circle()
            .fill(.brown.opacity(0.15))
        }
    }
    .padding(.horizontal)
    .padding(.top, 8)
    .transition(.opacity.combined(with: .scale))
  }
}

#Preview {
  HorizontalCalendar()
}
