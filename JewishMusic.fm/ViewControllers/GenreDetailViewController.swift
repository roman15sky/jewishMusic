//
//  GenreDetailViewController.swift
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

class GenreDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate ,GADBannerViewDelegate{

    public var genreID = Int()
    public var genreTitle = String()
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var genreAlbumsArray = [AlbumInfo]()
    var pageNum = Int()
    var isLoaded = Bool()
    var newFetchBool = 0
    
    var selected_Album_id = Int()
    var selected_Album_Title = String()
    
    
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
        
        self.titleLabel.text = genreTitle
        tableView.register(UINib(nibName: "PullDataTableViewCell", bundle: nil), forCellReuseIdentifier: "PullDataTableViewCell")
        pageNum = 1
        isLoaded = false
        
        self.requestGenreAlbum()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Button Actions
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        self.performSegue(withIdentifier: "goSearchFromGenresAlbumSegu", sender: nil)
    }
    
    @IBAction func onReload(_ sender: Any) {
        self.genreAlbumsArray = []
        self.pageNum = 1
        self.requestGenreAlbum()
    }
    
    // MARK: - Show Error
    func showError(erromsg : String){
        SCLAlertView().showError("Error", subTitle:erromsg, closeButtonTitle:"OK")
    }
    
    // MARK: - Request Album Detail
    func requestGenreAlbum() {
        let baseURL = Constants.getGenreAlbumAPI + "?lang=" + UserDefaults.standard.string(forKey: "language")! + "&genre_id=" + String(format: "%d", self.genreID) + "&page=" + String(format: "%d", self.pageNum)
        // Show MBProgress Loading View
        print(baseURL)
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = MBProgressHUDMode.indeterminate
        
        Alamofire.request(baseURL, method: .get, parameters: nil).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                //Hide MBProgress Loading View
                MBProgressHUD.hide(for: self.view, animated: true)
                let swiftyJsonVar = JSON(responseData.result.value!)
                print(swiftyJsonVar)
                
                if swiftyJsonVar.count > 1 {
                    for i in 0..<swiftyJsonVar.count-1 {
                        let index = String(format: "%d", i)
                        let album_id = swiftyJsonVar[index]["id"].intValue
                        
                        let title = swiftyJsonVar[index]["title"].string!
                        let attributedString = try? NSAttributedString(data: title.data(using: String.Encoding.unicode)!, options: [
                            .documentType: NSAttributedString.DocumentType.html,
                            .characterEncoding: String.Encoding.utf8.rawValue
                            ], documentAttributes: nil)
                        
                        
                        let thumbnail_images = swiftyJsonVar[index]["thumbnail_images"]["thumbnail"]["url"].string!
                        
                        var artistsArray = [String]()
                        for j in 0..<swiftyJsonVar[index]["taxonomy_artists"].count {
                            artistsArray.append(swiftyJsonVar[index]["taxonomy_artists"][j]["title"].string!)
                        }
                        
                        self.genreAlbumsArray.append(AlbumInfo.init(album_id: album_id, title: (attributedString?.string)!, thumbnail_images: thumbnail_images, taxonomy_artists: artistsArray))
                    }
                    self.tableView.reloadData()
                } else {
                    self.isLoaded = true
                    self.tableView.reloadData()
                }
                
            }else {
                //Hide MBProgress Loading View
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
        if isLoaded {
            return self.genreAlbumsArray.count
        } else {
            return self.genreAlbumsArray.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < self.genreAlbumsArray.count)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumsTableViewCell", for: indexPath) as! AlbumsTableViewCell
            
            cell.albumTitleLabel.text = self.genreAlbumsArray[indexPath.row].title
            
            self.setThumbnail(imgV: cell.albumThumbnailImageView, urlStr: self.genreAlbumsArray[indexPath.row].thumbnail_images.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            
            var artists = ""
            for i in 0..<self.genreAlbumsArray[indexPath.row].taxonomy_artists.count {
                let tmp = self.genreAlbumsArray[indexPath.row].taxonomy_artists[i]
                if i == 0 {
                    artists = tmp
                } else {
                    artists = artists + " , " + tmp
                }
            }
            
            cell.albumArtistNamesLabel.text = artists
            return cell
        } else {
            // Code to show Refersh cell
            let refreshCell = tableView.dequeueReusableCell(withIdentifier: "PullDataTableViewCell") as! PullDataTableViewCell
            refreshCell.startStopLoading(false)
            return refreshCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != self.genreAlbumsArray.count {
            self.selected_Album_id = self.genreAlbumsArray[indexPath.row].album_id
            self.selected_Album_Title = self.genreAlbumsArray[indexPath.row].title
            self.performSegue(withIdentifier: "goAlbumDetailFromGenreDetailSegue", sender: nil)
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
            let lastCellIndexPath = IndexPath(row:self.genreAlbumsArray.count , section: 0)
            let refreshCell = tv.cellForRow(at: lastCellIndexPath) as! PullDataTableViewCell
            refreshCell.startStopLoading(true)
            
            self.pageNum = self.pageNum + 1
            self.requestGenreAlbum()
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
        if segue.identifier == "goAlbumDetailFromGenreDetailSegue" {
            let albumDetailVC = segue.destination as? AlbumDetailViewController
            albumDetailVC?.album_id = self.selected_Album_id
            albumDetailVC?.album_title = self.selected_Album_Title
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
