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
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
    
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileControllerPresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        
        

        self.viewControllers = [imageListViewController, profileViewController]
    }
}
