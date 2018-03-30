//
//  ViewController.swift
//  weatherSharingApp
//
//  Created by user on 3/6/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import CoreData

protocol FacebookLoginProtocol {
    
    func login()
    func getFbUserInfo()
}

protocol LoginVcCoreDataProtocol {
    
    func updateUser(user: User, name: String, email: String)
    func insertUser(name: String, email: String)
    func saveMOC()
    func fetchUser(name: String) -> User?
    func filterUser(name: String, email: String)
}

protocol ApplyNewGradientDelegate: class {
    
    func gradientChanged(changed: Bool)
    
}

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var exploreInterestingAttributedLabel: UILabel!
    @IBOutlet weak var attributedTitleLabel: UILabel!
    
    let weatherForecasts = [WeatherForecast]()
    let toFindCityWeatherViiewControllerSegue = "ToFindCityWeatherViewControllerSegue"
    let moc = coreDataManager.persistentContainer.viewContext
    let fetchedResultsController = coreDataManager.fetchedResultsController
    var gradientChanged = false
    
    @IBAction func login(_ sender: Any) {
        login()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGradientFromDefaults()
        
        guard let userName = UserDefaults.standard.string(forKey: userName),
            let _ = fetchUser(name: userName) else { return }
        performSegue(withIdentifier: toFindCityWeatherViiewControllerSegue, sender: nil)
    }
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
//    MARK: Loading view methods
    
    func loadGradientFromDefaults() {
        guard let firstGradCol = UserDefaults.standard.string(forKey: firstGradientColor),
            let secondGradCol = UserDefaults.standard.string(forKey: secondGradientColor) else {
                UIView.insertGradient(in: view, hexStrings: (mainGradientColors.0, mainGradientColors.1))
                return
        }
        mainGradientColors.0 = firstGradCol
        mainGradientColors.1 = secondGradCol
        UIView.insertGradient(in: view, hexStrings: (firstGradCol, secondGradCol))
    }
    
    func replaceGradient(if changed: Bool) {
        if changed {
            
            let colors = (UIColor.init(hexString: mainGradientColors.0).cgColor , UIColor.init(hexString: mainGradientColors.1).cgColor)
            
            let newGradientLayer = CAGradientLayer().createGradientLayer(withColors: colors)
            newGradientLayer.frame = view.frame
            
            guard let currentGradientLayer = view.layer.sublayers?.first else { return }
            self.view.layer.replaceSublayer(currentGradientLayer, with: newGradientLayer)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updatingDefaultsInfo(name: String) {
        
        UserDefaults.standard.set(true, forKey: activeUser)
        UserDefaults.standard.set(name, forKey: userName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == toFindCityWeatherViiewControllerSegue {
            
            let destVC = segue.destination as! LoadWeatherViewController
            destVC.delegate = self
        }
    }
}

extension UIViewController: NSFetchedResultsControllerDelegate {
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case NSFetchedResultsChangeType(rawValue: 3)!:
            print("update")
            break
        case .insert:
          print("insert")
            break
        case .move:
            
            print("move")
            
        case .delete:
            print("delete")
            break
        
        case .update:
            print("update")
        }
    }
}

extension LoginViewController: FacebookLoginProtocol {
    func login() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) {[weak self] (result) in
            switch result {
            case .failed(let error):
                print(error.localizedDescription)
            case .cancelled:
                print("cancelled")
            case .success(grantedPermissions: _, declinedPermissions: _, token: let token):
                print(token)
                self!.getFbUserInfo()
            }
        }
    }
    
    func getFbUserInfo() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields" : "id,name,email"])
        request.start {[unowned self] (response, result) in
            switch result {
            case .failed(let error):
                print(error.localizedDescription)
            case .success(response: let fbGraphResponse):
                guard let userInfo = fbGraphResponse.dictionaryValue else { return }
                
                let name = userInfo["name"] as? String ??  "noName"
                self.updatingDefaultsInfo(name: name)
                
                guard let email = userInfo["email"] as? String else {
                    
                    DialogHelper.showAlert(title: "Dear \(name.components(separatedBy: " ").first!)", message: "You don't have email", controller: self, handleAction: nil)
                    
                    self.filterUser(name: name, email: "You have no email")
                    self.performSegue(withIdentifier: self.toFindCityWeatherViiewControllerSegue, sender: nil)
                    
                    return
                }
                
                self.filterUser(name: name, email: email)
                self.performSegue(withIdentifier: self.toFindCityWeatherViiewControllerSegue, sender: nil)
            }
        }
    }
}

extension LoginViewController: ApplyNewGradientDelegate {
    func gradientChanged(changed: Bool) {
        gradientChanged = changed
    }
}

extension LoginViewController: LoginVcCoreDataProtocol {
    
    func updateUser(user: User, name: String, email: String) {
        user.name = name
        user.email = email
        user.status = activeUser
       
    }
    
    func insertUser(name: String, email: String) {
        
        let newUser = User(context: moc)
        newUser.name = name
        newUser.email = email
        newUser.status = activeUser
      
        
    }
    
    func saveMOC() {
        do {
            try coreDataManager.saveMOC()
        } catch { print(error.localizedDescription) }
    }
    
    func fetchUser(name: String) -> User? {
        
        var user: User?
        
        fetchedResultsController.delegate = self
        guard UserDefaults.standard.bool(forKey: activeUser) else { return nil }
        self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name = %@", name)

        do {
            try coreDataManager.performFetch()
            guard let fetchedObjects = self.fetchedResultsController.fetchedObjects else { return nil }
            if fetchedObjects.count == 1 {
                user = fetchedObjects.first
            }
        } catch {
            print(error.localizedDescription)
        }
        return user
    }
    
    func filterUser(name: String, email: String) {
        
        
        if let user = fetchUser(name: name) {
            updateUser(user: user, name: name, email: email)
        } else {
            insertUser(name: name, email: email)
        }
        
        saveMOC()
    }
    
}


