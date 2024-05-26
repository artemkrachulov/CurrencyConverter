//
//  ActionToolbar.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit

final
class ActionToolbar: UIToolbar {

  var onDone: (() -> Void)?
  var onCancel: () -> Void

  init(onDone: @escaping () -> Void, onCancel: @escaping () -> Void) {
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

    let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))

    setItems([cancelButton, spaceButton, doneButton], animated: false)
    isUserInteractionEnabled = true
  }

  @objc private func doneTapped() {
    onDone?()
  }

  @objc private func cancelTapped() {
    onCancel()
  }
}
