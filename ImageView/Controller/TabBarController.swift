import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.ypBg
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        self.tabBar.standardAppearance = appearance
        let imageListViewController = ImageListViewController()
        imageListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
    
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        

        self.viewControllers = [imageListViewController, profileViewController]
    }
}
