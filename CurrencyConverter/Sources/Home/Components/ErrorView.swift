//
//  ErrorView.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit

final
class ErrorView: UIView {

  var error: String {
    didSet { label.text = error }
  }

  private
  lazy var label: UILabel = {
    let label = UILabel()
    label.text = error
    label.numberOfLines = 0
    label.textColor = .white
    label.font = AppFont.text
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  init(error: String) {
    self.error = error
    super.init(frame: .zero)

    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    backgroundColor = Asset.alert.color

    addSubview(label)
    label.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(GridLayout.u2)
    }
  }
}
