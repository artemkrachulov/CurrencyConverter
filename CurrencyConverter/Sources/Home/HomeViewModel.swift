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

  // MARK: I/O

  enum Output {
    case showError(String)
    case hideError
  }

  private
  let apiClient: Exchangeable

  let statusViewModel: StatusViewModel
  let firstExchangeViewModel: ExchangeViewModel
  let secondExchangeViewModel: ExchangeViewModel
  var error: PassthroughSubject<String?, Never> = .init()

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

  func transform() -> AnyPublisher<Output, Never> {

    let errorAction = error
      .map { error in
        if let error {
          return Output.showError(error)
        } else {
          return Output.hideError
        }
      }

    return errorAction.eraseToAnyPublisher()
  }

  // MARK: Timer
  // To save network recourses run timer only when currencies are different

  private
  var timer: Timer?

  private
  func startRefreshTimer() {
    let timer = Timer(timeInterval: 10.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    RunLoop.current.add(timer, forMode: .common)
    self.timer = timer
  }

  private
  func cancelRefreshTimer() {
    timer?.invalidate()
    timer = nil
  }

  @objc private
  func fireTimer(timer: Timer) {
    exchange(
      amount: firstExchangeViewModel.amount.value, of: firstExchangeViewModel.currency.value,
      update: secondExchangeViewModel)
  }
}

extension HomeViewModel {
  /// Shared refresh currency publisher
  private
  func exchange(amount: Double, of ofCurrency: Currency, update: Updatable) {

    cancelRefreshTimer()
    error.send(nil)

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
          self?.startRefreshTimer()
        case let .failure(error):
          self?.error.send(error.localizedDescription)
        }
      }.store(in: &networkCancellables)
  }
}
