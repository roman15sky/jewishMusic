//
//  SearchViewController.swift
//  JewishMusic.fm
//
//  Created by Admin on 30/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import SCLAlertView
import GoogleMobileAds

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource ,GADBannerViewDelegate{

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var search_ArtistsArray = [ArtistInfo]()
    var search_AlbumsArray = [AlbumInfo]()
    var search_TracksArray = [AlbumInfo]()
    
    var selected_id = Int()
    var selected_title = String()
    
    
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
        
        
        titleLabel.text = "Search".localized(lang: UserDefaults.standard.string(forKey: "language")!)
        // Do any additional setup after loading the view.
        searchTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Actions
    @IBAction func onBack(_ sender: Any) {
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - UITextfield Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text != "" {
            self.search_TracksArray = []
            self.search_ArtistsArray = []
            self.search_AlbumsArray = []
            self.requestSearch(keyStr: textField.text!)
        }
        return true
    }
    
    // MARK: - Show Error
    func showError(erromsg : String){
        SCLAlertView().showError("Error", subTitle:erromsg, closeButtonTitle:"OK")
    }
    
    // MARK: - Request
    func requestSearch(keyStr : String) {
        let baseURL = Constants.searchAPI + "?lang=" + UserDefaults.standard.string(forKey: "language")! + "&terms=" + keyStr
        // Show MBProgress Loading View
        print(baseURL)
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = MBProgressHUDMode.indeterminate
        
        Alamofire.request(baseURL, method: .get, parameters: nil).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                // Hide MBProgress Loading View
                MBProgressHUD.hide(for: self.view, animated: true)
                let swiftyJsonVar = JSON(responseData.result.value!)
                print(swiftyJsonVar)
                
                for i in 0..<swiftyJsonVar["artists"].count {
                    let artists_id = swiftyJsonVar["artists"][i]["id"].intValue
                    let artist_title = swiftyJsonVar["artists"][i]["title"].string!
                    let attributedString = try? NSAttributedString(data: artist_title.data(using: String.Encoding.unicode)!, options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                        ], documentAttributes: nil)
                    
                    let artist_image = swiftyJsonVar["artists"][i]["image"][0].string!
                    self.search_ArtistsArray.append(ArtistInfo.init(artist_id: artists_id, title: (attributedString?.string)!, thumbnail: artist_image))
                }
                
                for j in 0..<swiftyJsonVar["albums"].count {
                    let album_id = swiftyJsonVar["albums"][j]["id"].intValue
                    let album_title = swiftyJsonVar["albums"][j]["title"].string!
                    let attributedString = try? NSAttributedString(data: album_title.data(using: String.Encoding.unicode)!, options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                        ], documentAttributes: nil)
                    
                    let album_image = swiftyJsonVar["albums"][j]["image"][0].string!
                    var album_artistsArray = [String]()
                    for jj in 0..<swiftyJsonVar["albums"][j]["artists"].count {
                        album_artistsArray.append(swiftyJsonVar["albums"][j]["artists"][jj]["artist_name"].string!)
                    }
                    self.search_AlbumsArray.append(AlbumInfo.init(album_id: album_id, title: (attributedString?.string)!, thumbnail_images: album_image, taxonomy_artists: album_artistsArray))
                }
                
                for k in 0..<swiftyJsonVar["tracks"].count {
                    let track_id = swiftyJsonVar["tracks"][k]["id"].intValue
                    let track_title = swiftyJsonVar["tracks"][k]["title"].string!
                    let attributedString = try? NSAttributedString(data: track_title.data(using: String.Encoding.unicode)!, options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                        ], documentAttributes: nil)
                    
                    var track_image = ""
                    if swiftyJsonVar["tracks"][k]["image"] == false {
                        track_image = ""
                    } else {
                        track_image = swiftyJsonVar["tracks"][k]["image"][0].string!
                    }
                    
                    var track_artistsArray = [String]()
                    if swiftyJsonVar["tracks"][k]["artists"] != JSON.null {
                        for kk in 0..<swiftyJsonVar["tracks"][k]["artists"].count {
                            track_artistsArray.append(swiftyJsonVar["tracks"][k]["artists"][kk]["artist_name"].string!)
                        }
                    }else{
                        track_artistsArray = []
                    }
                    self.search_TracksArray.append(AlbumInfo.init(album_id: track_id, title: (attributedString?.string)!, thumbnail_images: track_image, taxonomy_artists: track_artistsArray))
                }
                self.tableView.reloadData()
            }else {
                // Hide MBProgress Loading View
                MBProgressHUD.hide(for: self.view, animated: true)
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
        return self.search_ArtistsArray.count + self.search_AlbumsArray.count + self.search_TracksArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumsTableViewCell", for: indexPath) as! AlbumsTableViewCell
        if indexPath.row < self.search_ArtistsArray.count {
            self.setThumbnail(imgV: cell.albumThumbnailImageView, urlStr: self.search_ArtistsArray[indexPath.row].thumbnail.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            cell.albumTitleLabel.text = self.search_ArtistsArray[indexPath.row].title
            cell.albumArtistNamesLabel.text = "Artist"
        } else if indexPath.row >= self.search_ArtistsArray.count && indexPath.row < (self.search_ArtistsArray.count + self.search_AlbumsArray.count) {
            self.setThumbnail(imgV: cell.albumThumbnailImageView, urlStr: self.search_AlbumsArray[indexPath.row - self.search_ArtistsArray.count].thumbnail_images.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            cell.albumTitleLabel.text = self.search_AlbumsArray[indexPath.row - self.search_ArtistsArray.count].title
            cell.albumArtistNamesLabel.text = "Album"
        } else if indexPath.row >= (self.search_ArtistsArray.count + self.search_AlbumsArray.count) && indexPath.row < (self.search_ArtistsArray.count + self.search_AlbumsArray.count + self.search_TracksArray.count) {
            if self.search_TracksArray[indexPath.row - self.search_ArtistsArray.count - self.search_AlbumsArray.count].thumbnail_images == "" {
                cell.albumThumbnailImageView.image = UIImage()
            } else {
                self.setThumbnail(imgV: cell.albumThumbnailImageView, urlStr: self.search_TracksArray[indexPath.row - self.search_ArtistsArray.count - self.search_AlbumsArray.count].thumbnail_images.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            }
            cell.albumTitleLabel.text = self.search_TracksArray[indexPath.row - self.search_ArtistsArray.count - self.search_AlbumsArray.count].title
            cell.albumArtistNamesLabel.text = "Track"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.search_ArtistsArray.count {
            //Artist
            self.selected_id = self.search_ArtistsArray[indexPath.row].artist_id
            self.selected_title = self.search_ArtistsArray[indexPath.row].title
            self.performSegue(withIdentifier: "goArtistDetailFromSearchSegue", sender: nil)
        } else if indexPath.row >= self.search_ArtistsArray.count && indexPath.row < (self.search_ArtistsArray.count + self.search_AlbumsArray.count) {
            //Album
            self.selected_id = self.search_AlbumsArray[indexPath.row - self.search_ArtistsArray.count].album_id
            self.selected_title = self.search_AlbumsArray[indexPath.row - self.search_ArtistsArray.count].title
            self.performSegue(withIdentifier: "goAlbumdetailFromSearchSegue", sender: nil)
        } else if indexPath.row >= (self.search_ArtistsArray.count + self.search_AlbumsArray.count) && indexPath.row < (self.search_ArtistsArray.count + self.search_AlbumsArray.count + self.search_TracksArray.count) {
            //Track
            self.selected_id = self.search_TracksArray[indexPath.row - self.search_ArtistsArray.count - self.search_AlbumsArray.count].album_id
            self.selected_title = self.search_TracksArray[indexPath.row - self.search_ArtistsArray.count - self.search_AlbumsArray.count].title
            self.performSegue(withIdentifier: "goAlbumdetailFromSearchSegue", sender: nil)
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
        if segue.identifier == "goArtistDetailFromSearchSegue" {
            let artistDetailVC = segue.destination as? ArtistDetailViewController
            artistDetailVC?.artistID = self.selected_id
            artistDetailVC?.artistTitle = self.selected_title
        } else if segue.identifier == "goAlbumdetailFromSearchSegue" {
            let albumDetailVC = segue.destination as? AlbumDetailViewController
            albumDetailVC?.album_id = self.selected_id
            albumDetailVC?.album_title = self.selected_title
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
