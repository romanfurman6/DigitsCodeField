//
//  ViewController.swift
//  DigitsCodeField
//
//  Created by Roman Furman on 15.01.2020.
//  Copyright © 2020 uptech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let digitsCodeField = DigitsCodeField()
    let label = UILabel()
    let button = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        digitsCodeField.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Valid code: 111111"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Validate", for: .normal)
        button.addTarget(self, action: #selector(validateField), for: .touchUpInside)
        view.addSubview(digitsCodeField)
        view.addSubview(label)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 470),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            digitsCodeField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            digitsCodeField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        let gesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(gesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        digitsCodeField.becomeFirstResponder()
    }

    @objc
    func endEditing() {
        view.endEditing(true)
    }

    @objc
    func validateField() {
        digitsCodeField.resignFirstResponder()
        if digitsCodeField.text != "111111" {
            digitsCodeField.updateUI(with: .isValid(false))
            let alert = UIAlertController(title: "💥", message: "Code is wrong, nice try!", preferredStyle: .alert)
            alert.addAction(.init(title: "Retry", style: .cancel, handler: { [weak self] _ in
                self?.digitsCodeField.text = ""
                self?.digitsCodeField.becomeFirstResponder()
            }))
            present(alert, animated: true, completion: nil)
        } else {
            digitsCodeField.updateUI(with: .isValid(true))
            let alert = UIAlertController(title: "🚀", message: "You're great!", preferredStyle: .alert)
            alert.addAction(.init(title: "Yey", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

