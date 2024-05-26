//
//  AppCurrencyFormatterTest.swift
//  CurrencyConverterTests
//
//  Created by Artem Krachulov on 26.05.2024.
//

import XCTest
@testable import CurrencyConverter

final class AppCurrencyFormatterTest: XCTestCase {

  var formatter: AppCurrencyFormatter!

  override func setUp() {
    super.setUp()
    formatter = AppCurrencyFormatter.shared
  }

  override func tearDown() {
    formatter = nil
    super.tearDown()
  }

  func testFormatToCurrencyFromValidString() {
    let result = formatter.formatToCurrency(from: "1234.56")
    XCTAssertEqual(result, "1,234.56", "Formatted string is incorrect")
  }

  func testFormatToCurrencyFromInvalidString() {
    let result = formatter.formatToCurrency(from: "invalid")
    XCTAssertEqual(result, "0.00", "Formatted string should be 0.00 for invalid input")
  }

  func testFormatToCurrencyFromNilString() {
    let result = formatter.formatToCurrency(from: nil)
    XCTAssertEqual(result, "0.00", "Formatted string should be 0.00 for nil input")
  }

  func testFormatToCurrencyFromDouble() {
    let result = formatter.formatToCurrency(from: 7890.12)
    XCTAssertEqual(result, "7,890.12", "Formatted double is incorrect")
  }

  // Additional tests
  func testFormatToCurrencyFromEmptyString() {
    let result = formatter.formatToCurrency(from: "")
    XCTAssertEqual(result, "0.00", "Formatted string should be 0.00 for empty input")
  }
}
