
import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarController()

    }
    
    private func setupTabBarController() {
        
        let vc1 = UINavigationController(rootViewController: DocumentsViewController())
        let vc2 = UINavigationController(rootViewController: SettingsViewController())
        
        vc1.title = "Документы"
        vc2.title = "Настройки"
        
        vc1.tabBarItem.image = UIImage(systemName: "folder.fill")
        vc2.tabBarItem.image = UIImage(systemName: "gearshape.fill")
    
        tabBar.barTintColor = .white
        setViewControllers([vc1, vc2], animated: false)
    }
    
    


}
