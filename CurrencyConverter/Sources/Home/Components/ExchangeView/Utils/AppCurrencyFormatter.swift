//
//  AppCurrencyFormatter.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Foundation

final
class AppCurrencyFormatter {

  static let shared = AppCurrencyFormatter()

  private init() {}

  private
  lazy var enFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .currency
    formatter.currencySymbol = ""
    return formatter
  }()

  func formatToCurrency(from text: String?) -> String? {
    let double: Double
    if let text {
      double = Double(text) ?? 0
    } else { double = 0 }
    return formatToCurrency(from: double)
  }

  func formatToCurrency(from amount: Double) -> String? {
    enFormatter.string(for: amount)
  }
}
