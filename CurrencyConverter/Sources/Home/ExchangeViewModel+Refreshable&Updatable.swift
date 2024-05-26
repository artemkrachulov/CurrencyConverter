//
//  ExchangeViewModel+Refreshable&Updatable.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Combine

protocol Refreshable {
  var refresh: AnyPublisher<(Double, Currency), Never> { get }
}

protocol Updatable {
  var currency: CurrentValueSubject<Currency, Never> { get }
  var amount: CurrentValueSubject<Double, Never> { get }
}

extension ExchangeViewModel: Updatable {}

extension ExchangeViewModel: Refreshable {

  var refresh: AnyPublisher<(Double, Currency), Never> {
    input
      .share()
      .compactMap { [unowned self] action in
        switch action {
        case .setActive:
          return nil
        case .currencySelected(let currency):
          return (amount.value, currency)
        case .textFieldEndEditing(let amount):
          return (amount, currency.value)
        }
      }
      .eraseToAnyPublisher()
  }
}
