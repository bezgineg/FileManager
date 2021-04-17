
import UIKit

enum Keys: String {
    case sortingBoolKey
    case imageSizeShowingBoolKey
    case isFirstLaunchBoolKey
}

class SettingsViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let reuseID = "ReuseID"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Настройки"

        setupTableView()
        setupLayout()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupSortingSwitchControl(_ switchControl: UISwitch) {
        let boolValue = UserDefaults.standard.bool(forKey: Keys.sortingBoolKey.rawValue)
        if boolValue {
            switchControl.setOn(true, animated: true)
        } else {
            switchControl.setOn(false, animated: true)
        }
        switchControl.addTarget(self, action: #selector(self.sortingSwitchChanged(_:)), for: .valueChanged)
    }
    
    private func setupImageSizeSwitchControl(_ switchControl: UISwitch) {
        let boolValue = UserDefaults.standard.bool(forKey: Keys.imageSizeShowingBoolKey.rawValue)
        if boolValue {
            switchControl.setOn(true, animated: true)
        } else {
            switchControl.setOn(false, animated: true)
        }
        switchControl.addTarget(self, action: #selector(self.imageSizeSwitchChanged(_:)), for: .valueChanged)
    }
    
    @objc private func sortingSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: Keys.sortingBoolKey.rawValue)
        } else {
            UserDefaults.standard.setValue(false, forKey: Keys.sortingBoolKey.rawValue)
        }
    }
    
    @objc private func imageSizeSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: Keys.imageSizeShowingBoolKey.rawValue)
        } else {
            UserDefaults.standard.setValue(false, forKey: Keys.imageSizeShowingBoolKey.rawValue)
        }
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        let constraints = [
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 2 else { return }
        let vc = PasswordViewController()
        present(vc, animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
                
        switch indexPath.section {
            case 0:
                let switchControl = UISwitch(frame: .zero)
                setupSortingSwitchControl(switchControl)
                cell.accessoryView = switchControl
                cell.textLabel?.text = "Сортировка по алфавиту или в обратном порядке"
            case 1:
                let switchControl = UISwitch(frame: .zero)
                setupImageSizeSwitchControl(switchControl)
                cell.accessoryView = switchControl
                cell.textLabel?.text = "Показать размер фото"
            case 2:
                cell.textLabel?.text = "Изменить пароль"
                cell.textLabel?.textColor = .systemRed
            default:
                break
        }
        
        return cell
    }
    
    
}
