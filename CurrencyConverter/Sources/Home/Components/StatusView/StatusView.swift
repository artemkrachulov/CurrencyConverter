//
//  StatusView.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit
import Combine

final
class StatusView: UIView {

  private
  lazy var refreshDateLabel: UILabel = {
    let label = UILabel()
    label.text = "---"
    label.textColor = Asset.primary.color
    label.font = AppFont.text
    return label
  }()

  private
  let activityIndicatorView: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = .medium
    activityIndicator.color = Asset.primary.color
    return activityIndicator
  }()

  private
  lazy var clockView: UIImageView = {
    let view = UIImageView(image: UIImage(systemName: AppIcon.clock))
    view.tintColor = Asset.primary.color
    return view
  }()

  let viewModel: StatusViewModel

  private
  var cancellables = Set<AnyCancellable>()

  init(viewModel: StatusViewModel) {
    self.viewModel = viewModel
    super.init(frame: .zero)

    setupUI()
    setupBindings()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {

    let activityContainerView = UIView()
    activityContainerView.translatesAutoresizingMaskIntoConstraints = false
    activityContainerView.snp.makeConstraints { make in
      make.width.height.equalTo(Layout.iconSize)
    }

    [activityIndicatorView, clockView]
      .forEach { view in
        activityContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
          make.edges.equalToSuperview()
        }
      }

    let hStack = UIStackView(arrangedSubviews: [
      activityContainerView,
      refreshDateLabel
    ])
    hStack.spacing = GridLayout.u
    hStack.axis = .horizontal

    let vStack = UIStackView(arrangedSubviews: [hStack])
    vStack.axis = .vertical
    vStack.alignment = .center
    vStack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(vStack)

    vStack.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(GridLayout.u3)
      make.leading.trailing.equalToSuperview()
    }
  }

  private func setupBindings() {
    viewModel
      .transform()
      .sink { [unowned self] event in
        switch event {
        case let .setLoading(isLoading):
          if isLoading {
            activityIndicatorView.startAnimating()
          } else {
            activityIndicatorView.stopAnimating()
          }
          clockView.isHidden = isLoading

        case let .setRefreshDate(date):
          refreshDateLabel.text = L10n.refreshAt(date)
        }
      }.store(in: &cancellables)
  }
}
