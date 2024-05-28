//
//  ApiError.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Foundation

enum ApiError: Error, LocalizedError {
  case generic(String)
}

extension ApiError {

  public var errorDescription: String? {
    return L10n.genericError
  }
}
