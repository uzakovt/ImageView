import UIKit

final class ProfileViewController: UIViewController {
    private var userName = UILabel()
    private var fullName = UILabel()
    private var userBio = UILabel()
    private var profileImageView = UIImageView()
    private var logOutButton = UIButton()
    private let authStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        profilePicture()
        fullNameLabel()
        userNameLabel()
        userBioLabel()
        logOutButtonView()
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "token")
    }
    
    private func profilePicture(){
        let profileImage = UIImage(named: "userPic")
        profileImageView.image = profileImage
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    private func fullNameLabel(){
        fullName.text = "Екатерина Новикова"
        fullName.font = UIFont.boldSystemFont(ofSize: 23)
        fullName.textColor = .white
        fullName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullName)
        
        NSLayoutConstraint.activate([
            fullName.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            fullName.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor)
        ])
    }
    
    private func userNameLabel(){
        userName.text = "@ekaterina_nov"
        userName.font = UIFont.systemFont(ofSize: 13)
        userName.textColor = .gray
        userName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userName)
        
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor)
        ])
    }
    
    private func userBioLabel(){
        userBio.text = "Hello, world!"
        userBio.font = UIFont.systemFont(ofSize: 13)
        userBio.textColor = .white
        userBio.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userBio)
        
        NSLayoutConstraint.activate([
            userBio.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            userBio.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor)
        ])
    }
    
    private func logOutButtonView(){
        logOutButton = UIButton.systemButton(
            with: UIImage(named: "exit") ?? UIImage(),
            target: self,
            action: #selector(logOutButtonPressed)
        )
        logOutButton.tintColor = .ypRed
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logOutButton)
        
        NSLayoutConstraint.activate([
            logOutButton.widthAnchor.constraint(equalToConstant: 45),
            logOutButton.heightAnchor.constraint(equalToConstant: 45),
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logOutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
            
        ])
    }
}
