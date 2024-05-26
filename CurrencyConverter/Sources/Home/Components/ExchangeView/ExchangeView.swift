//
//  ExchangeView.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit
import SnapKit
import Combine

final
class ExchangeView: UIView {

  private
  lazy var codeLabel: UILabel = {
    let label = UILabel()
    return label
  }()

  private
  lazy var selectIcon: UIImageView = {
    let view = UIImageView(image: UIImage(systemName: "chevron.down"))
    view.translatesAutoresizingMaskIntoConstraints = false
    view.snp.makeConstraints { make in
      make.width.height.equalTo(14)
    }
    return view
  }()

  private
  lazy var symbolLabel: UILabel = {
    let label = UILabel()
    label.setContentHuggingPriority(.init(200), for: .horizontal)
    label.textAlignment = .right
    label.translatesAutoresizingMaskIntoConstraints = false
    label.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(30)
    }
    return label
  }()

  private
  lazy var pickerView: UIPickerView = {
    let picker = UIPickerView()
    picker.backgroundColor = .white
    picker.delegate = self
    picker.dataSource = self
    return picker
  }()

  private
  lazy var pickerTextField: UITextField = {
    let textField = UITextField()

    let toolBar = ActionToolbar { [unowned self] in
      let index = pickerView.selectedRow(inComponent: 0)
      let currency = Currency(rawValue: index)!
      viewModel.input.send(.currencySelected(currency: currency))
      endEditing(true)
    } onCancel: { [unowned self] in
      endEditing(true)
    }
    textField.keyboardType = .decimalPad
    textField.inputView = pickerView
    textField.inputAccessoryView = toolBar
    textField.isHidden = true

    return textField
  }()

  private
  lazy var textField: UITextField = {
    let textField = HitlessTextField()
    textField.delegate = self
    textField.keyboardType = .decimalPad
    let toolBar = ActionToolbar { [unowned self] in
      endEditing(true)
    } onCancel: { [unowned self] in
      endEditing(true)
    }
    toolBar.translatesAutoresizingMaskIntoConstraints = false
    textField.inputAccessoryView = toolBar
    textField.autocorrectionType = .no
    textField.autocapitalizationType = .none
    return textField
  }()

  private
  var viewModel: ExchangeViewModel

  private
  var cancellables = Set<AnyCancellable>()

  private
  var valueValidator: ValueValidator

  /// Flag determines when textfield should erase on edit
  private
  var shouldClear: Bool = false

  init(viewModel: ExchangeViewModel, valueValidator: ValueValidator = DoubleValueValidator()) {
    self.viewModel = viewModel
    self.valueValidator = valueValidator
    super.init(frame: .zero)

    setupUI()
    setupBindings()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {

    addSubview(pickerTextField)

    let selectionStack = UIStackView(arrangedSubviews: [
      codeLabel,
      selectIcon
    ])
    selectionStack.spacing = 8

    let selectionView = UIView()
    selectionView.addSubview(selectionStack)
    selectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentPicker(_:))))
    selectionView.translatesAutoresizingMaskIntoConstraints = false
    selectionStack.snp.makeConstraints { make in
      make.edges.equalTo(selectionView)
        .inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }

    let stack = UIStackView(arrangedSubviews: [
      selectionView,
      symbolLabel,
      textField
    ])
    stack.spacing = 8
    stack.alignment = .center

    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }

    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentNumPad(_:))))
  }

  private func setupBindings() {

    viewModel.isActive
      .sink { [unowned self] isActive in
        textField.textColor = isActive ? .blue : .black
      }.store(in: &cancellables)

    viewModel
      .transform()
      .sink { [unowned self] event in
        switch event {
        case let .updateTextField(text):
          textField.text = text

        case let .updateCurrency(currency):
          codeLabel.text = currency.code
          symbolLabel.text = currency.symbol
        }
      }.store(in: &cancellables)
  }

  @objc private
  func presentPicker(_ sender: UITapGestureRecognizer?) {
    pickerView.selectRow(viewModel.currency.value.rawValue, inComponent: 0, animated: false)
    pickerTextField.becomeFirstResponder()
  }

  @objc private
  func presentNumPad(_ sender: UITapGestureRecognizer?) {
    textField.becomeFirstResponder()
  }
}

// MARK: UITextFieldDelegate

extension ExchangeView: UITextFieldDelegate {

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    shouldClear = true

    DispatchQueue.main.async {
      let position = textField.endOfDocument
      textField.selectedTextRange = textField.textRange(from: position, to: position)
    }
    viewModel.input.send(.setActive(true))
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    if shouldClear {
      if valueValidator.validate(string) {
        textField.text = ""
        shouldClear = false
        return true
      } else {
        return false
      }
    }

    let currentText = textField.text ?? ""
    let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
    return valueValidator.validate(prospectiveText)
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    viewModel.input.send(.textFieldEndEditing(amount: textField.text.doubleOrZero))
    viewModel.input.send(.setActive(false))
  }
}

// MARK: UIPickerViewDelegate

extension ExchangeView: UIPickerViewDelegate, UIPickerViewDataSource {

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return Currency.allCases.count
  }

  // The data to return for the row and component (column) that's being passed in
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return Currency.allCases[row].code
  }
}

// MARK: Utils

fileprivate
extension Optional where Wrapped == String {
  var doubleOrZero: Double {
    if let self {
      return Double(self) ?? 0
    } else {
      return 0
    }
  }
}

fileprivate
extension Currency {

  var symbol: String {
    switch self {
    case .EUR:
      return "€"
    case .USD:
      return "$"
    case .UAH:
      return "₴"
    }
  }
}
