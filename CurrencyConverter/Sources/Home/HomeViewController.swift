//
//  HomeViewController.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit
import Combine

final
class HomeViewController: UIViewController {

  private
  lazy var titleLabel: UILabel = {
    var label = UILabel()
    label.text = L10n.homeTitle
    label.font = .systemFont(ofSize: 32, weight: .bold)
    label.textColor = Asset.primary.color
    return label
  }()

  private
  lazy var descLabel: UILabel = {
    var label = UILabel()
    label.text = L10n.homeDesc
    label.textAlignment = .center
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 14, weight: .regular)
    label.textColor = Asset.secondary.color
    return label
  }()

  private
  lazy var exchangeStackView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private
  var cancellables = Set<AnyCancellable>()

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
    setupBindings()
  }

  private
  func setupUI() {

    self.view.backgroundColor = Asset.background.color

    let headerView = UIView()
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.backgroundColor = .white
    view.addSubview(headerView)
    headerView.snp.makeConstraints { make in
      make.top.equalTo(view.snp.top)
      make.leading.trailing.equalToSuperview()
    }

    let headerStack = UIStackView(arrangedSubviews: [
      titleLabel,
      descLabel
    ])
    headerStack.spacing = 16
    headerStack.axis = .vertical
    headerStack.alignment = .center
    headerStack.translatesAutoresizingMaskIntoConstraints = false
    headerView.addSubview(headerStack)
    headerStack.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
      make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(32)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(32)
      make.bottom.equalTo(headerView.snp.bottom).offset(-32)
    }

    let statusView = StatusView(viewModel: viewModel.statusViewModel)
    statusView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(statusView)
    statusView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom)
      make.leading.trailing.equalToSuperview()
    }

    view.addSubview(exchangeStackView)
    exchangeStackView.snp.makeConstraints { make in
      make.top.equalTo(statusView.snp.bottom)
      make.leading.trailing.equalToSuperview()
    }

    let dividerView = UIView()
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.backgroundColor = Asset.background.color
    dividerView.snp.makeConstraints { make in
      make.height.equalTo(1)
    }

    let dividerContainerView = UIView()
    dividerContainerView.addSubview(dividerView)
    dividerView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(16)
    }

    let exchangeStack = UIStackView(arrangedSubviews: [
      ExchangeView(viewModel: viewModel.firstExchangeViewModel),
      dividerContainerView,
      ExchangeView(viewModel: viewModel.secondExchangeViewModel)
    ])
    exchangeStack.spacing = 8
    exchangeStack.axis = .vertical
    exchangeStackView.translatesAutoresizingMaskIntoConstraints = false
    exchangeStackView.addSubview(exchangeStack)
    exchangeStack.snp.makeConstraints { make in
      make.edges.equalTo(exchangeStackView)
    }
  }

  private
  func setupBindings() {
    viewModel
      .transform()
      .sink { [unowned self] event in
        switch event {
        case let .showError(error):
          showError(error)

        case .hideError:
          errorView?.removeFromSuperview()
        }
      }.store(in: &cancellables)
  }

  private
  var errorView: ErrorView?

  private func showError(_ error: String) {
    if let errorView {
      errorView.error = error
    } else {
      let errorView = ErrorView(error: error)
      errorView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(errorView)
      errorView.snp.makeConstraints { make in
        make.left.right.equalToSuperview()
        make.top.equalTo(exchangeStackView.snp.bottom)
      }
      self.errorView = errorView
    }
  }
}
