//
//  SettingsViewController.swift
//  JewishMusic.fm
//
//  Created by Admin on 26/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit
import FAPanels
import SCLAlertView
import GoogleMobileAds

protocol SettingsViewControllerDelegate {
    func changeLanguage()
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    var settingsArray = [SettingObject]()
    
    var delegate : SettingsViewControllerDelegate?
    
    
    @IBOutlet var advertisingView: UIView!
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-2132873164239431/5622245664"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adBannerView.load(GADRequest())
        // Do any additional setup after loading the view.
        self.initSettings()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSettings() {
        titleLabel.text = "Settings".localized(lang: UserDefaults.standard.string(forKey: "language")!)
        
        settingsArray = []
        
        settingsArray.append(SettingObject.init(titleStr: "About".localized(lang: UserDefaults.standard.string(forKey: "language")!), describeStr: "Information about our application".localized(lang: UserDefaults.standard.string(forKey: "language")!)))
        
        settingsArray.append(SettingObject.init(titleStr: "Rate this app".localized(lang: UserDefaults.standard.string(forKey: "language")!), describeStr: "Help other users enjoy this application".localized(lang: UserDefaults.standard.string(forKey: "language")!)))
        
        settingsArray.append(SettingObject.init(titleStr: "Select Language".localized(lang: UserDefaults.standard.string(forKey: "language")!), describeStr: "Default language".localized(lang: UserDefaults.standard.string(forKey: "language")!)))
        
        settingsArray.append(SettingObject.init(titleStr: "Privacy".localized(lang: UserDefaults.standard.string(forKey: "language")!), describeStr: "Find our privacy policy here".localized(lang: UserDefaults.standard.string(forKey: "language")!)))
        
        tableView.reloadData()
    }
    
    //MARK: - Button Actions
    @IBAction func onMenu(_ sender: Any) {
        panel?.openLeft(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITableView Delegate & UItableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.titleLabel.text = self.settingsArray[indexPath.row].titleStr
        cell.descriptionLabel.text = self.settingsArray[indexPath.row].describeStr
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            // create an actionSheet
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // create an action
            let firstAction: UIAlertAction = UIAlertAction(title: "English".localized(lang: UserDefaults.standard.string(forKey: "language")!), style: .default) { action -> Void in
                UserDefaults.standard.set("en", forKey: "language")
                self.delegate?.changeLanguage()
                self.initSettings()
            }
            
            let secondAction: UIAlertAction = UIAlertAction(title: "Hebrew".localized(lang: UserDefaults.standard.string(forKey: "language")!), style: .default) { action -> Void in
                UserDefaults.standard.set("he", forKey: "language")
                self.delegate?.changeLanguage()
                self.initSettings()
            }
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
            
            // add actions
            actionSheetController.addAction(firstAction)
            actionSheetController.addAction(secondAction)
            actionSheetController.addAction(cancelAction)
            
            // present an actionSheet...
            present(actionSheetController, animated: true, completion: nil)
        } else if indexPath.row == 0 {
            let appearance = SCLAlertView.SCLAppearance(
                showCircularIcon: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.showSuccess("About", subTitle: "Version2.0 \nThank you for downloading our app \nBy JewishMusic.fm")
            
        } else if indexPath.row == 3 {
            let appearance = SCLAlertView.SCLAppearance(
                showCircularIcon: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.showSuccess("Privacy", subTitle: "Find our privacy policy here. \nhttp://jewishmusic.fm/privacy-policy/")
        } else if indexPath.row == 1 {
            let appID = "959379869"
            if let checkURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8") {
                open(url: checkURL)
            } else {
                print("invalid url")
            }
        }
    }
    
    func open(url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open \(url): \(success)")
            })
        } else if UIApplication.shared.openURL(url) {
            print("Open \(url)")
        }
    }

    
    //MARK: - GADBanner Delegate
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        advertisingView.addSubview(bannerView)
        
    }
    
}
