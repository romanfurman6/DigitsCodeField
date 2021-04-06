//
//  DigitsCodeField.swift
//  DigitsCodeField
//
//  Created by Roman Furman on 15.01.2020.
//  Copyright © 2019 uptech. All rights reserved.
//

import UIKit

extension UIColor {
    class CodeFieldColor {
        static let background = UIColor.black
        static let border = UIColor.lightGray
        static let error = UIColor.red
        static let valid = UIColor.green
        static let digitSelected = UIColor.lightGray
        static let digitDeselected = UIColor.darkGray
    }
}

class DigitsCodeField: UIView {

    var text: String? {
        set {
            codeField.text = newValue
        }
        get {
            return codeField.text
        }
    }
    enum State {
        case isEditing(Bool)
        case isValid(Bool)
    }
    private lazy var stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16.0
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isUserInteractionEnabled = true
        return sv
    }()
    private lazy var codeField = CodeTextField()
    private let menuController = UIMenuController.shared
    private let maxDigitsCount: Int


    init(maxDigitsCount: Int = 6) {
        self.maxDigitsCount = maxDigitsCount
        super.init(frame: .zero)
        setUpAppearance()
        setUpViews()
        setUpConstraints()
        setUpActions()
        codeField.delegate = self
    }


    required init?(coder: NSCoder) {
        let msg = "\(String(describing: type(of: self))) cannot be used with a nib file."
        fatalError(msg)
    }


    func updateUI(with state: State) {
        let numbers = codeField.text?.map(String.init).compactMap(Int.init) ?? []
        guard (0...maxDigitsCount).contains(numbers.count) else {
            return
        }
        let isAnimatingPlaceholder: Bool
        switch state {
        case let .isEditing(value):
            displayMenuController(!value)
            isAnimatingPlaceholder = value

        case .isValid:
            displayMenuController(false)
            isAnimatingPlaceholder = false

        }
        layer.borderColor = state.color.cgColor
        for offset in 0..<maxDigitsCount {
            guard let digitView = stack.arrangedSubviews[offset] as? DigitView else {
                return
            }
            // configure digit view
            let state = digitViewState(for: offset, numbers: numbers, color: state.color)
            digitView.configure(with: state)
            // animate placeholder if it first after numbers
            let isAnimatingPlaceholder = offset == numbers.count && isAnimatingPlaceholder
            animatePlaceholder(isAnimatingPlaceholder, view: digitView)
        }
    }


    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return codeField.becomeFirstResponder()
    }


    @discardableResult
    override func resignFirstResponder() -> Bool {
        return codeField.resignFirstResponder()
    }

}



// MARK: - Private methods

private extension DigitsCodeField {

    func digitViewState(for offset: Int, numbers: [Int], color: UIColor) -> DigitViewState {
        switch offset {
        case 0..<numbers.count:
            let attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30.0, weight: .medium),
                NSAttributedString.Key.foregroundColor: color
            ]
            return .label(NSAttributedString(string: "\(numbers[offset])", attributes: attributes))
        default:
            return .placeholder(color)
        }
    }


    func animatePlaceholder(_ isAnimating: Bool, view: DigitView) {
        if isAnimating {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse], animations: {
                view.configure(with: .placeholder(UIColor.CodeFieldColor.digitDeselected))
            }, completion: nil)
        } else {
            view.placeholder.layer.removeAllAnimations()
        }
    }


    func displayMenuController(_ isVisible: Bool = true) {
        if isVisible && !menuController.isMenuVisible {
            if #available(iOS 13.0, *) {
                menuController.showMenu(from: self, rect: codeField.frame)
            } else {
                menuController.setTargetRect(codeField.frame, in: self)
                menuController.setMenuVisible(true, animated: true)
            }
        } else {
            if #available(iOS 13.0, *) {
                menuController.hideMenu(from: self)
            } else {
                menuController.setTargetRect(codeField.frame, in: self)
                menuController.setMenuVisible(false, animated: true)
            }
        }
    }


    func setUpActions() {
        codeField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPressGesture(recognizer:))
        )
        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(longPressGesture)
    }


    func setUpAppearance() {
        backgroundColor = UIColor.CodeFieldColor.background
        layer.borderColor = UIColor.CodeFieldColor.border.cgColor
        layer.borderWidth = 1.0
    }


    func setUpViews() {
        addSubview(codeField)
        addSubview(stack)
        (0..<maxDigitsCount).forEach { _ in
            stack.addArrangedSubview(makeDigitView())
        }
    }


    func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        let hInset: CGFloat = 28.0
        let vInset: CGFloat = 42.0
        constraints += [
            stack.topAnchor.constraint(equalTo: topAnchor, constant: hInset),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: vInset),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0 * hInset),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.0 * vInset)
        ]
        constraints += [
            codeField.widthAnchor.constraint(equalToConstant: 0.0),
            codeField.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            codeField.topAnchor.constraint(equalTo: stack.topAnchor),
            codeField.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }


    func makeDigitView() -> UIView {
        let vw = DigitView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }

}



// MARK: - Actions

extension DigitsCodeField {

    @objc
    func textFieldEditingChanged(_ textField: UITextField) {
        updateUI(with: .isEditing(textField.isEditing))
    }


    @objc
    func handleLongPressGesture(recognizer: UIGestureRecognizer) {
        if !codeField.isFirstResponder {
            codeField.becomeFirstResponder()
        }
        displayMenuController()
    }


    @objc
    func handleTapGesture(recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if codeField.isFirstResponder {
                displayMenuController()
            } else {
                codeField.becomeFirstResponder()
            }
        default:
            break
        }
    }

}



// MARK: - DigitsCodeField.State

extension DigitsCodeField.State {
    var color: UIColor {
        switch self {
        case let .isEditing(value):
            return value ? UIColor.CodeFieldColor.digitSelected : UIColor.CodeFieldColor.digitDeselected
        case let .isValid(value):
            return value ? UIColor.CodeFieldColor.valid : UIColor.CodeFieldColor.error
        }
    }
}



// MARK: - DigitView

extension DigitsCodeField {

    enum DigitViewState {
        case label(NSAttributedString)
        case placeholder(UIColor)
    }



    class DigitView: UIView {

        private lazy var label: UILabel = {
            let lbl = UILabel()
            lbl.numberOfLines = 1
            lbl.textAlignment = .center
            lbl.translatesAutoresizingMaskIntoConstraints = false
            return lbl
        }()
        private(set) lazy var placeholder: UIView = {
            let vw = UIView()
            vw.translatesAutoresizingMaskIntoConstraints = false
            return vw
        }()


        init() {
            super.init(frame: .zero)
            setUpViews()
            setUpConstraints()
        }


        required init?(coder: NSCoder) {
            let msg = "\(String(describing: type(of: self))) cannot be used with a nib file."
            fatalError(msg)
        }


        private func setUpViews() {
            addSubview(label)
            addSubview(placeholder)
        }


        func configure(with state: DigitViewState) {
            switch state {
            case let .label(attributedString):
                placeholder.isHidden = true
                label.attributedText = attributedString
                label.isHidden = false
            case let .placeholder(color):
                label.isHidden = true
                placeholder.backgroundColor = color
                placeholder.isHidden = false
            }
        }


        private func setUpConstraints() {
            var constraints = [NSLayoutConstraint]()
            constraints += [
                widthAnchor.constraint(equalToConstant: 18.0),
                heightAnchor.constraint(equalToConstant: 26.0)
            ]
            constraints += [
                label.topAnchor.constraint(equalTo: topAnchor),
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
            constraints += [
                placeholder.topAnchor.constraint(equalTo: topAnchor, constant: 5.0),
                placeholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1.0),
                placeholder.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0 * 5.0),
                placeholder.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.0)
            ]
            NSLayoutConstraint.activate(constraints)
        }

    }

}



// MARK: - CodeTextField

extension DigitsCodeField {

    class CodeTextField: UITextField {

        init() {
            super.init(frame: .zero)
            self.textColor = .clear
            self.keyboardAppearance = .dark
            self.borderStyle = .none
            self.keyboardType = .numberPad
            self.tintColor = .clear
            self.translatesAutoresizingMaskIntoConstraints = false
            self.textContentType = .oneTimeCode
        }


        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            // pasting only allowed
            if action == #selector(paste(_:)) {
                return true
            }
            return false
        }


        override func paste(_ sender: Any?) {
            // clear current textField text before pasting
            text = ""
            // send action that text was edited
            self.sendActions(for: .editingChanged)
            super.paste(sender)
        }


        required init?(coder: NSCoder) {
            let msg = "\(String(describing: type(of: self))) cannot be used with a nib file."
            fatalError(msg)
        }
    }

}



// MARK: - UITextFieldDelegate

extension DigitsCodeField: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        // allowed length rule
        let newLength = text.count + string.count - range.length
        let isAllowedLength = newLength <= maxDigitsCount
        // allowed chars rule
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        let isAllowedChars = allowedCharacters.isSuperset(of: characterSet)
        return isAllowedChars && isAllowedLength
    }


    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateUI(with: .isEditing(true))
    }


    func textFieldDidEndEditing(_ textField: UITextField) {
        updateUI(with: .isEditing(false))
    }

} // swiftlint:disable:this file_length
