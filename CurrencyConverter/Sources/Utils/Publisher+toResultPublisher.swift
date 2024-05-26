//
//  Publisher+toResultPublisher.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import Combine

extension Publisher {
  func toResultPublisher() -> AnyPublisher<Result<Output, Failure>, Never> {
    self
      .map { Result.success($0) }
      .catch { Just(Result.failure($0)) }
      .eraseToAnyPublisher()
  }
}
