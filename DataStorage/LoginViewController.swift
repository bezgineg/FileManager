
import UIKit
import KeychainAccess

class LoginViewController: UIViewController {
    
    var buttonTitle: String?
    
    var passwordItems = [String]()
    
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
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        updateKeychainData()
        setupButtonTitle()
        setupLayout()
    }
    
    private func updateKeychainData() {
        let keychain = Keychain(service: KeychainConfiguration.serviceName)
        passwordItems = keychain.allKeys()
    }
    
    private func setupButtonTitle() {
        if passwordItems.isEmpty {
            buttonTitle = "Создать пароль"
        } else {
            buttonTitle = "Введите пароль"
        }
    }
    
    @objc private func buttonTapped() {
        if textField.text?.count == 4 {
            checkingPassword()
        } else {
            let title = "Пароль должен состоять из 4 символов"
            showAlert(with: title)
        }
    }
    
    private func checkingPassword() {
        switch logInButton.currentTitle {
        case "Создать пароль":
            createPassword()
            logInButton.setTitle("Введите пароль", for: .normal)
            textField.text = ""
        case "Введите пароль":
            if checkingKeychainPassword() {
                logInButton.setTitle("Повторите пароль", for: .normal)
                textField.text = ""
            } else {
                let title = "Неверный пароль"
                showAlert(with: title)
                textField.text = ""
            }
        case "Повторите пароль":
            if checkingKeychainPassword() {
                let tabBarVC = TabBarController()
                navigationController?.pushViewController(tabBarVC, animated: true)
            } else {
                let title = "Пароль не совпадает"
                showAlert(with: title)
                textField.text = ""
                logInButton.setTitle("Введите пароль", for: .normal)
            }
        default:
            break
        }
    }
    
    private func createPassword() {
        guard let password = textField.text, !password.isEmpty else { return }
        let keychain = Keychain(service: KeychainConfiguration.serviceName)
        let accountName = "User"
        keychain[accountName] = password
        passwordItems = keychain.allKeys()
    }
    
    private func checkingKeychainPassword() -> Bool {
        if let password = textField.text, !password.isEmpty {
            let keychain = Keychain(service: KeychainConfiguration.serviceName)
            let accountName = "User"
            if password == keychain[accountName] {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
        
    }
    
    private func showAlert(with title: String) {
        let alertController = UIAlertController(title: title, message: "Попробуйте еще раз", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        navigationController?.present(alertController, animated: false, completion: nil)
    }
    
    private func setupLayout() {
        view.addSubview(textField)
        view.addSubview(logInButton)

        let constraints = [
                        
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: 200),
            
            logInButton.topAnchor.constraint(equalTo: textField.bottomAnchor),
            logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            logInButton.widthAnchor.constraint(equalToConstant: 200),

        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}


