//
//  ExchangeViewModel.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Combine

final
class ExchangeViewModel {

  // MARK: I/O

  enum Input {
    case setActive(Bool)
    case currencySelected(currency: Currency)
    case textFieldEndEditing(amount: Double)
  }

  enum Output {
    case updateCurrency(currency: Currency)
    case updateTextField(text: String?)
  }

  let input: PassthroughSubject<Input, Never> = .init()

  // MARK: UI Reflections

  var isActive: CurrentValueSubject<Bool, Never> = .init(false)
  var currency: CurrentValueSubject<Currency, Never>
  var amount: CurrentValueSubject<Double, Never>

  private
  var cancellables = Set<AnyCancellable>()

  init(amount: Double, currency: Currency) {
    self.amount = CurrentValueSubject(amount)
    self.currency = CurrentValueSubject(currency)
  }

  func transform() -> AnyPublisher<Output, Never> {
    input
      .sink { [unowned self] event in
        switch event {
        case let .textFieldEndEditing(amount):
          self.amount.send(amount)

        case let .currencySelected(currency):
          self.currency.send(currency)

        case let .setActive(isActive):
          self.isActive.send(isActive)
        }
      }
      .store(in: &cancellables)

    let amountAction = amount
      .map(AppCurrencyFormatter.shared.formatToCurrency(from:))
      .map(Output.updateTextField)

    let currencyAction = currency
      .map(Output.updateCurrency)

    return Publishers.Merge(
      amountAction,
      currencyAction
    ).eraseToAnyPublisher()
  }
}
