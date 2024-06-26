//
//  ExchangeView.swift
//  CurrencyConverter
//
//  Created by Artem Krachulov on 26.05.2024.
//

import UIKit
import SnapKit
import Combine

// We want to process formatting only for specific text field
private
let amountTextFieldTag = 757 // ✈️

final
class ExchangeView: UIView {

  private
  lazy var codeLabel: UILabel = {
    let label = UILabel()
    label.font =  AppFont.code
    label.textColor = .white
    return label
  }()

  private
  lazy var selectIcon: UIImageView = {
    let view = UIImageView(image: UIImage(systemName: AppIcon.chevron))
    view.translatesAutoresizingMaskIntoConstraints = false
    view.tintColor = .white
    view.snp.makeConstraints { make in
      make.width.height.equalTo(Layout.iconSize)
    }
    return view
  }()

  private
  lazy var symbolLabel: UILabel = {
    let label = UILabel()
    label.setContentHuggingPriority(.init(200), for: .horizontal)
    label.textAlignment = .right
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = AppFont.amount
    label.textColor = Asset.primary.color
    return label
  }()

  private
  lazy var selectionView: UIView = {
    let view = CorneredView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = Asset.primary.color
    return view
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
    textField.delegate = self
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
    textField.tag = amountTextFieldTag
    textField.keyboardType = .decimalPad
    let toolBar = ActionToolbar { [unowned self] in
      endEditing(true)
    }
    toolBar.translatesAutoresizingMaskIntoConstraints = false
    textField.inputAccessoryView = toolBar
    textField.autocorrectionType = .no
    textField.autocapitalizationType = .none
    textField.font =  AppFont.amount
    textField.textColor = Asset.primary.color
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
    selectionStack.alignment = .center
    selectionStack.spacing = GridLayout.u2

    selectionView.addSubview(selectionStack)
    selectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentPicker(_:))))
    selectionView.snp.makeConstraints { make in
      make.height.equalTo(Layout.selectionHeight)
    }

    selectionStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(AppLayout.edgeInset)
      make.centerY.equalToSuperview()
    }

    let stack = UIStackView(arrangedSubviews: [
      selectionView,
      symbolLabel,
      textField
    ])
    stack.spacing = GridLayout.u2
    stack.alignment = .center

    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(AppLayout.edgeInset)
      make.top.bottom.equalToSuperview().inset(AppLayout.edgeInset)
    }

    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentNumPad(_:))))
  }

  private func setupBindings() {

    viewModel.isActive
      .sink { [unowned self] isActive in
        let color = isActive ? Asset.accentColor.color : Asset.primary.color
        selectionView.backgroundColor = color
        symbolLabel.textColor = color
        textField.textColor = color
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

    viewModel.input.send(.setActive(true))

    guard isAmountTextFeld(textField) else {
      return true
    }

    shouldClear = true

    DispatchQueue.main.async {
      let position = textField.endOfDocument
      textField.selectedTextRange = textField.textRange(from: position, to: position)
    }
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    guard isAmountTextFeld(textField) else {
      return true
    }

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

    viewModel.input.send(.setActive(false))

    guard isAmountTextFeld(textField) else {
      return
    }
    viewModel.input.send(.textFieldEndEditing(amount: textField.text.doubleOrZero))
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
    case .FAKE:
      return "F"
    }
  }
}

private
func isAmountTextFeld(_ textField: UITextField) -> Bool {
  textField.tag == amountTextFieldTag
}
