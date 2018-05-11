//
//  ArtistsViewController.swift
//  JewishMusic.fm
//
//  Created by Admin on 26/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit
import FAPanels
import Alamofire
import SwiftyJSON
import MBProgressHUD
import SCLAlertView
import GoogleMobileAds

class ArtistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate ,GADBannerViewDelegate{

    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    var artistsArray = [ArtistInfo]()
    var pageNum = Int()
    var isLoaded = Bool()
    var newFetchBool = 0
    
    var selected_artistID = Int()
    var selected_artistTitle = String()
    
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
        
        titleLabel.text = "Artists".localized(lang: UserDefaults.standard.string(forKey: "language")!)
        
        tableView.register(UINib(nibName: "PullDataTableViewCell", bundle: nil), forCellReuseIdentifier: "PullDataTableViewCell")
        pageNum = 1
        isLoaded = false
        self.requestGetArtists()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Button Actions
    @IBAction func onMenu(_ sender: Any) {
        panel?.openLeft(animated: true)
    }
    
    @IBAction func onReload(_ sender: Any) {
        self.artistsArray = []
        self.pageNum = 1
        self.requestGetArtists()
    }
    
    @IBAction func onSearch(_ sender: Any) {
        self.performSegue(withIdentifier: "goSearchFromArtistsSegu", sender: nil)
    }
    
    // MARK: - Show Error
    func showError(erromsg : String){
        SCLAlertView().showError("Error", subTitle:erromsg, closeButtonTitle:"OK")
    }
    
    // MARK: - Request
    func requestGetArtists() {
        let baseURL = Constants.getArtistAPI + "?lang=" + UserDefaults.standard.string(forKey: "language")! + "&page=" + String(format: "%d", pageNum)
        // Show MBProgress Loading View
        print(baseURL)
        //        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        //        loading.mode = MBProgressHUDMode.indeterminate
        
        Alamofire.request(baseURL, method: .get, parameters: nil).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                // Hide MBProgress Loading View
                //                MBProgressHUD.hide(for: self.view, animated: true)
                let swiftyJsonVar = JSON(responseData.result.value!)
                if swiftyJsonVar.count > 1 {
                    for i in 0..<swiftyJsonVar.count-2 {
                        let index = String(format: "%d", i)
                        let artist_id = swiftyJsonVar[index]["id"].intValue
                        
                        let title = swiftyJsonVar[index]["title"].string!
                        let attributedString = try? NSAttributedString(data: title.data(using: String.Encoding.unicode)!, options: [
                            .documentType: NSAttributedString.DocumentType.html,
                            .characterEncoding: String.Encoding.utf8.rawValue
                            ], documentAttributes: nil)
                        
                        
                        let thumbnail = swiftyJsonVar[index]["thumbnail"].string!
                        
                        self.artistsArray.append(ArtistInfo.init(artist_id: artist_id, title: (attributedString?.string)!, thumbnail: thumbnail))
                    }
                    self.tableView.reloadData()
                } else {
                    self.isLoaded = true
                    self.tableView.reloadData()
                }
                
            }else {
                // Hide MBProgress Loading View
                //                MBProgressHUD.hide(for: self.view, animated: true)
                self.showError(erromsg: "Please check your Network Connection.")
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - UITableView Delegate & Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoaded {
            return self.artistsArray.count
        } else {
            return self.artistsArray.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < self.artistsArray.count)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistsTableViewCell", for: indexPath) as! ArtistsTableViewCell
            
            self.setThumbnail(imgV: cell.artistImageView, urlStr: self.artistsArray[indexPath.row].thumbnail.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            
            cell.artistNameLabel.text = self.artistsArray[indexPath.row].title

            return cell
        } else {
            // Code to show Refersh cell
            let refreshCell = tableView.dequeueReusableCell(withIdentifier: "PullDataTableViewCell") as! PullDataTableViewCell
            refreshCell.startStopLoading(false)
            return refreshCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != self.artistsArray.count {
            self.selected_artistID = self.artistsArray[indexPath.row].artist_id
            self.selected_artistTitle = self.artistsArray[indexPath.row].title
            self.performSegue(withIdentifier: "goArtistDetailFromArtistsSegue", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        newFetchBool = 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        newFetchBool += 1
        
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if(decelerate && newFetchBool >= 2 && scrollView.contentOffset.y >= 0 && !isLoaded)
        {
            let tv =  scrollView as! UITableView
            let lastCellIndexPath = IndexPath(row:self.artistsArray.count , section: 0)
            let refreshCell = tv.cellForRow(at: lastCellIndexPath) as! PullDataTableViewCell
            refreshCell.startStopLoading(true)

            self.pageNum = self.pageNum + 1
            self.requestGetArtists()
            newFetchBool = 0
        }
        else if(!decelerate)
        {
            newFetchBool = 0
        }
    }
    
    // MARK: - Download Image
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func setThumbnail(imgV : UIImageView, urlStr : String) {
        getDataFromUrl(url: URL(string: urlStr)!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                imgV.image = UIImage(data: data)!
            }
        }
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goArtistDetailFromArtistsSegue" {
            let artistDetailVC = segue.destination as? ArtistDetailViewController
            artistDetailVC?.artistID = self.selected_artistID
            artistDetailVC?.artistTitle = self.selected_artistTitle
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
