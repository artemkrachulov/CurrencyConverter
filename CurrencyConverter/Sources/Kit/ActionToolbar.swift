//
//  ActionToolbar.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit

final
class ActionToolbar: UIToolbar {

  private
  var onDone: () -> Void

  private
  var onCancel: (() -> Void)?

  init(onDone: @escaping () -> Void, onCancel: (() -> Void)? = nil) {
    self.onDone = onDone
    self.onCancel = onCancel
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private
  func setup() {
    barStyle = UIBarStyle.default
    isTranslucent = true
    tintColor = .black
    sizeToFit()

    var items = [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
    ]

    if onCancel?() != nil {
      items.insert(
        UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped)), at: 0
      )
    }

    setItems(items, animated: false)

    isUserInteractionEnabled = true
  }

  @objc private func doneTapped() {
    onDone()
  }

  @objc private func cancelTapped() {
    onCancel?()
  }
}
