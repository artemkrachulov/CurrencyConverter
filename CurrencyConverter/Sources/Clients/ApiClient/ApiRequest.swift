//
//  ApiRequest.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Foundation
import Moya

enum ApiRequest {

  // Example
  // http://api.evp.lt/currency/commercial/exchange/340.51-EUR/UAH/latest
  case exchange(amount: Double, ofCurrency: Currency, onCurrency: Currency)
}

// MARK: - TargetType Protocol Implementation

extension ApiRequest: TargetType {

  var baseURL: URL { URL(string: "http://api.evp.lt")! } // s?
  var path: String {
    switch self {
    case let .exchange(amount, ofCurrency, onCurrency):
      return "/currency/commercial/exchange/\(amount)-\(ofCurrency.code)/\(onCurrency.code)/latest"
    }
  }
  var method: Moya.Method {
    switch self {
    case .exchange:
      return .get
    }
  }
  var task: Task {
    .requestPlain
  }

  var sampleData: Data {
    Data()
  }

  var headers: [String: String]? {
    return ["Content-type": "application/json"]
  }
}
