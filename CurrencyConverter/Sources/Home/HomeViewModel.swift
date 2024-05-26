//
//  HomeViewModel.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Foundation
import Combine

final
class HomeViewModel {

  private
  let apiClient: Exchangeable

  let statusViewModel: StatusViewModel
  let firstExchangeViewModel: ExchangeViewModel
  let secondExchangeViewModel: ExchangeViewModel

  private
  var cancellables = Set<AnyCancellable>()

  private
  var networkCancellables = Set<AnyCancellable>()

  init(statusViewModel: StatusViewModel, firstExchangeViewModel: ExchangeViewModel, secondExchangeViewModel: ExchangeViewModel, apiClient: Exchangeable) {

    self.statusViewModel = statusViewModel
    self.firstExchangeViewModel = firstExchangeViewModel
    self.secondExchangeViewModel = secondExchangeViewModel
    self.apiClient = apiClient
    setup()
  }

  static let live: HomeViewModel = {
    HomeViewModel(
      statusViewModel: .init(),
      firstExchangeViewModel: .init(amount: 100, currency: .EUR),
      secondExchangeViewModel: .init(amount: 100, currency: .EUR),
      apiClient: ApiExchangeClient())
  }()

  private
  func setup() {

    firstExchangeViewModel
      .refresh
      .sink { [unowned self] (amount, currency) in
        exchange(
          amount: amount, of: currency,
          update: secondExchangeViewModel)
      }.store(in: &cancellables)

    secondExchangeViewModel
      .refresh
      .sink { [unowned self] (amount, currency) in
        exchange(
          amount: amount, of: currency,
          update: firstExchangeViewModel)
      }.store(in: &cancellables)
  }
}

extension HomeViewModel {
  /// Shared refresh currency publisher
  private
  func exchange(amount: Double, of ofCurrency: Currency, update: Updatable) {

    networkCancellables.forEach { $0.cancel() }
    networkCancellables = []

    let toCurrency = update.currency.value

    guard ofCurrency != toCurrency else {
      update.amount.send(amount)
      return
    }
    statusViewModel.isLoading.send(true)
    return apiClient
      .exchange(amount: amount, of: ofCurrency, on: toCurrency)
      .map(\.amount)
      .toResultPublisher()
      .subscribe(on: DispatchQueue.networking)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        self?.statusViewModel.isLoading.send(false)
        switch result {
        case let .success(response):
          update.amount.send(response)
          self?.statusViewModel.refreshDate.send(Date())
        case let .failure(error):
          fatalError(error.localizedDescription)
        }
      }.store(in: &networkCancellables)
  }
}
