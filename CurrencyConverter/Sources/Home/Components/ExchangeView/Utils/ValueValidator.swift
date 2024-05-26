//
//  ValueValidator.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Foundation

protocol ValueValidator {
  func validate(_ string: String?) -> Bool
}

final
class DoubleValueValidator: ValueValidator {
  func validate(_ string: String?) -> Bool {
    guard let string else { return false }
    return Double(string) != nil
  }
}

final
class DoubleValueValidatorStub: ValueValidator {
  func validate(_ string: String?) -> Bool {
    true
  }
}
