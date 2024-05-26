//
//  ExchangeView.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit

final
class ExchangeView: UIView {

  private
  let viewModel: ExchangeViewModel

  init(viewModel: ExchangeViewModel) {
    self.viewModel = viewModel
    super.init(frame: .zero)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
