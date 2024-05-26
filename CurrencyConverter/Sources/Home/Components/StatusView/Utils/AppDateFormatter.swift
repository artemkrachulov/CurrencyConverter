//
//  AppDateFormatter.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Foundation

final
class AppDateFormatter {

  public
  static let shared = AppDateFormatter()

  private
  init() {}

  private
  lazy var timeOfDayTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateStyle = .none
    formatter.timeStyle = .medium

    return formatter
  }()

  func formattedDate(from date: Date) -> String {
    return timeOfDayTimeFormatter.string(from: date)
  }
}
