//
//  ApiExchangeClient.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Combine
import Moya
import CombineMoya
import Foundation

protocol Exchangeable {

  func exchange(amount: Double, of ofCurrency: Currency, on onCurrency: Currency) -> AnyPublisher<ExchangeResponse, ApiError>
}

extension DispatchQueue {
  static let networking = DispatchQueue(label: "networking", qos: .utility)
}

final
class ApiExchangeClient: Exchangeable {

  lazy var provider = MoyaProvider<ApiRequest>(plugins: [NetworkLoggerPlugin()])

  func exchange(amount: Double, of ofCurrency: Currency, on onCurrency: Currency) -> AnyPublisher<ExchangeResponse, ApiError> {
    return provider
      .requestPublisher(.exchange(amount: amount, ofCurrency: ofCurrency, onCurrency: onCurrency))
      .map(\.data)
      .decode(type: ExchangeResponse.self, decoder: JSONDecoder())
      .mapError { error in
        ApiError.generic(error.localizedDescription)
      }
      .eraseToAnyPublisher()
  }
}
