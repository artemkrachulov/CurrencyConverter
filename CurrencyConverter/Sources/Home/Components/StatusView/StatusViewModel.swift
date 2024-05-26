//
//  StatusViewModel.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Combine
import Foundation

final
class StatusViewModel {

  // MARK: I/O

  enum Output {
    case setLoading(isLoading: Bool)
    case setRefreshDate(String)
  }

  var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
  var refreshDate: PassthroughSubject<Date, Never> = .init()

  func transform() -> AnyPublisher<Output, Never> {

    let loadingAction = isLoading
      .map(Output.setLoading)

    let refreshDateAction = refreshDate
      .map(AppDateFormatter.shared.formattedDate(from:))
      .map(Output.setRefreshDate)

    return Publishers.Merge(
      loadingAction,
      refreshDateAction
    ).eraseToAnyPublisher()
  }
}
