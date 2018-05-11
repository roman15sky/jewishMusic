//
//  LeftMenuViewController.swift
//  JewishMusic.fm
//
//  Created by Admin on 26/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit
import FAPanels

class LeftMenuViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, SettingsViewControllerDelegate {

    @IBOutlet var tableView: UITableView!
    
    public var menuOptions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuOptions = ["Recent Albums".localized(lang: UserDefaults.standard.string(forKey: "language")!), "Artists".localized(lang: UserDefaults.standard.string(forKey: "language")!), "Genres".localized(lang: UserDefaults.standard.string(forKey: "language")!), "Favorites".localized(lang: UserDefaults.standard.string(forKey: "language")!), "Settings".localized(lang: UserDefaults.standard.string(forKey: "language")!)]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - UITableView Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuTableViewCell") as! LeftMenuTableViewCell
        cell.menuTitleLabel.text = menuOptions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RecentAlbumsVC")
            let centerNavVC = UINavigationController(rootViewController: centerVC)
            panel!.configs.bounceOnCenterPanelChange = true
            _ = panel!.center(centerNavVC)
        } else if indexPath.row == 1 {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ArtistsVC")
            let centerNavVC = UINavigationController(rootViewController: centerVC)
            panel!.configs.bounceOnCenterPanelChange = true
            _ = panel!.center(centerNavVC)
        } else if indexPath.row == 2 {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "GenresVC")
            let centerNavVC = UINavigationController(rootViewController: centerVC)
            panel!.configs.bounceOnCenterPanelChange = true
            _ = panel!.center(centerNavVC)
        } else if indexPath.row == 3 {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "FavoritesVC")
            let centerNavVC = UINavigationController(rootViewController: centerVC)
            panel!.configs.bounceOnCenterPanelChange = true
            _ = panel!.center(centerNavVC)
        } else if indexPath.row == 4 {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC: SettingsViewController = mainStoryboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsViewController
            centerVC.delegate = self
            let centerNavVC = UINavigationController(rootViewController: centerVC)
            panel!.configs.bounceOnCenterPanelChange = true
            _ = panel!.center(centerNavVC)
        }
        
    }

    
    //MARK: - SettingsViewController Delegate
    func changeLanguage() {
        menuOptions = ["Recent Albums".localized(lang: UserDefaults.standard.string(forKey: "language")!), "Artists".localized(lang: UserDefaults.standard.string(forKey: "language")!), "Genres".localized(lang: UserDefaults.standard.string(forKey: "language")!), "Favorites".localized(lang: UserDefaults.standard.string(forKey: "language")!), "Settings".localized(lang: UserDefaults.standard.string(forKey: "language")!)]
        self.tableView.reloadData()
    }
}

extension String {
    func localized(lang:String) ->String {
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
