//
//  HomeViewController.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit

final
class HomeViewController: UIViewController {

  private lazy var titleLabel: UILabel = {
    var label = UILabel()
    label.text = "My title"
    return label
  }()

  private lazy var descLabel: UILabel = {
    var label = UILabel()
    label.text = "My desc"
    return label
  }()

  var viewModel: HomeViewModel

  init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
  }

  private
  func setupUI() {

    self.view.backgroundColor = .white

    let headerView = UIView()
    headerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(headerView)
    headerView.snp.makeConstraints { make in
      make.top.equalTo(view.snp.top)
      make.leading.trailing.equalToSuperview()
    }

    let headerStack = UIStackView(arrangedSubviews: [
      titleLabel,
      descLabel
    ])
    headerStack.axis = .vertical
    headerStack.alignment = .center
    headerStack.translatesAutoresizingMaskIntoConstraints = false
    headerView.addSubview(headerStack)
    headerStack.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
      make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
      make.bottom.equalTo(headerView.snp.bottom).offset(-32)
    }

    let statusView = StatusView(viewModel: viewModel.statusViewModel)
    statusView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(statusView)
    statusView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom)
      make.leading.trailing.equalToSuperview()
    }

    let exchangeStackView = UIView()
    exchangeStackView.backgroundColor = .white
    exchangeStackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(exchangeStackView)
    exchangeStackView.snp.makeConstraints { make in
      make.top.equalTo(statusView.snp.bottom)
      make.leading.trailing.equalToSuperview()
    }

    let exchangeStack = UIStackView(arrangedSubviews: [
      ExchangeView(viewModel: viewModel.firstExchangeViewModel),
      ExchangeView(viewModel: viewModel.secondExchangeViewModel)
    ])
    exchangeStack.axis = .vertical
    exchangeStackView.translatesAutoresizingMaskIntoConstraints = false
    exchangeStackView.addSubview(exchangeStack)
    exchangeStack.snp.makeConstraints { make in
      make.edges.equalTo(exchangeStackView)
    }
  }
}
