//
//  HorizontalCalendarViewModel.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 27/01/2026.
//

import SwiftUI

@Observable
class HorizontalCalendarViewModel {

  // MARK: - Properties

  var selectedDate: Date?

  private(set) var dates: [Date] = []
  private var cachedToday: Date
  let calendar = Calendar.current

  // Today is computed fresh each time to handle day changes
  var today: Date {
    calendar.startOfDay(for: Date())
  }

  // MARK: - Init

  init() {
    let calendar = Calendar.current
    let initialToday = calendar.startOfDay(for: Date())

    self.cachedToday = initialToday
    self.selectedDate = initialToday

    rebuildDates(for: initialToday)
  }

  // MARK: - Day Change Handling

  func refreshIfNeeded() {
    let currentToday = today
    if currentToday != cachedToday {
      cachedToday = currentToday
      rebuildDates(for: currentToday)
    }
  }

  private func rebuildDates(for today: Date) {
    let startDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
    let endDate = calendar.date(byAdding: .day, value: 5, to: today)!

    var result: [Date] = []
    var current = startDate

    while current <= endDate {
      result.append(current)
      current = calendar.date(byAdding: .day, value: 1, to: current)!
    }

    self.dates = result
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
    if isFuture(date) {
      return 0
    }
    return DailyProgressManager.shared.completedCount(for: date)
  }

  func totalCount(for date: Date) -> Int {
    if isFuture(date) {
      return 4 // Default total groups
    }
    return DailyProgressManager.shared.totalCount(for: date)
  }
  
  func daysDifferenceFromToday(_ date: Date) -> Int {
    calendar.dateComponents([.day], from: date, to: today).day ?? 0
  }
}
