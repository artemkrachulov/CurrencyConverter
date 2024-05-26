//
//  HomeViewController.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit

final
class HomeViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let exchangeView = ExchangeView(viewModel: .init(amount: 100, currency: .EUR), valueValidator: DoubleValueValidator())

    exchangeView.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 100))
    view.addSubview(exchangeView)
  }
}
