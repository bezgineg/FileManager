

import UIKit
import KeychainAccess

class PasswordViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.placeholder = "Введите пароль"
        return textField
    }()
    
    private lazy var logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Изменить пароль", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupLayout()
        getPassword()
        
    }
    
    @objc private func buttonTapped() {
        if textField.text?.count == 4 {
            changePassword()
            let title = "Пароль изменен"
            showAlert(with: title)
        } else {
            let title = "Пароль должен состоять из 4 символов"
            showAlert(with: title)
        }
    }
    
    private func changePassword() {
        guard let password = textField.text, !password.isEmpty else { return }
        let keychain = Keychain(service: KeychainConfiguration.serviceName)
        let accountName = "User"
        keychain[accountName] = password
        label.text = "Текущий пароль: \(password)"
    }
    
    private func getPassword() {
        let keychain = Keychain(service: KeychainConfiguration.serviceName)
        let accountName = "User"
        guard let password = keychain[accountName] else { return }
        label.text = "Текущий пароль: \(password)"
    }
    
    private func showAlert(with title: String) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: false, completion: nil)
    }
    
    private func setupLayout() {
        view.addSubview(textField)
        view.addSubview(logInButton)
        view.addSubview(label)

        let constraints = [
                        
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: 300),
            
            logInButton.topAnchor.constraint(equalTo: textField.bottomAnchor),
            logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            logInButton.widthAnchor.constraint(equalToConstant: 300),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 50),
            label.widthAnchor.constraint(equalToConstant: 300),
            label.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -50)

        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

}
