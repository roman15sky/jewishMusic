//
//  AlbumDetailViewController.swift
//  JewishMusic.fm
//
//  Created by Admin on 27/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import SCLAlertView
import GoogleMobileAds
import ZSWTappableLabel

class AlbumDetailViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, GADBannerViewDelegate, ZSWTappableLabelTapDelegate {
    
    public var album_id = Int()
    public var album_title = String()
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableHeaderContainer: UIView!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var albumTitleLabel: UILabel!
    
    @IBOutlet var albumArtistLabel: ZSWTappableLabel!
    //    @IBOutlet var albumArtistLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var addFavoriteButton: UIButton!
    @IBOutlet var addCartButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    
    var albumThumbnailImageUrl = String()
    var albumTitle = String()
    var albumArtist = String()
    var albumCartUrl = String()
    var albumTrackArray = [AlbumDetailInfo]()
    var albumArtistArray = [ArtistInfo]()
    
    var selected_artistID = Int()
    var selected_artistTitle = String()
    
    @IBOutlet var albumArtistLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var thumbnailImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var subViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var playerContainerView: UIView!
    @IBOutlet var playerContainerViewHeightConstraint: NSLayoutConstraint!
    
    var avPlyerVC : AVAudioPlayerViewController?
    
    
    
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
        
        
        titleLabel.text = album_title
        addCartButton.isHidden = true
        addFavoriteButton.isHidden = true
        moreButton.isHidden = true
        // Do any additional setup after loading the view.
        self.requestAlbumDetail()
        
        if AudioPlayer.sharedInstance.player.isPlaying {
            playerContainerView.isHidden = false
            playerContainerViewHeightConstraint.constant = 80
        } else {
            playerContainerView.isHidden = true
            playerContainerViewHeightConstraint.constant = 0
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Actions
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onReload(_ sender: Any) {
        albumTrackArray = []
        self.requestAlbumDetail()
    }
    
    @IBAction func onAddFavorite(_ sender: Any) {
        for i in 0..<self.albumTrackArray.count {
            if self.albumTrackArray[i].trackLiked == false {
                self.albumTrackArray[i].trackLiked = true
                self.addTrackToFavorites(idx: i)
            }
        }
        self.tableView.reloadData()
    }
    
    @IBAction func onAddCart(_ sender: Any) {
        self.performSegue(withIdentifier: "goWebViewSegue", sender: nil)
    }
    
    @IBAction func onLike(_ sender: UIButton) {
        print(sender.tag)
        if self.albumTrackArray[sender.tag].trackLiked == true {
            sender.setImage(UIImage(named: "BtnLike"), for: .normal)
            self.albumTrackArray[sender.tag].trackLiked = false
            self.removeTrackToFavorites(idx: sender.tag)
        } else {
            sender.setImage(UIImage(named: "BtnLiked"), for: .normal)
            self.albumTrackArray[sender.tag].trackLiked = true
            self.addTrackToFavorites(idx: sender.tag)
        }
    }
    
    @IBAction func onMoreOrLess(_ sender: Any) {
        if self.moreButton.titleLabel?.text == "More" {
            self.moreButton.setTitle("Less", for: .normal)
            
            
            albumArtistLabel.text = self.albumArtist
            for i in 0..<self.albumArtistArray.count {
                if let attributedText = albumArtistLabel.attributedText?.mutableCopy() as? NSMutableAttributedString {
                    let range = (attributedText.string as NSString).range(of: self.albumArtistArray[i].title)
                    if range.location != NSNotFound {
                        attributedText.addAttributes([
                            .tappableRegion: true,
                            .link:self.albumArtistArray[i].title,
                            .underlineColor : UIColor.clear
                            ], range: range)
                    }
                    albumArtistLabel.attributedText = attributedText
                }
            }
            
            self.albumArtistLabelHeightConstraint.constant = heightForView(text: self.albumArtist, font: UIFont.systemFont(ofSize: 14.0), width: UIScreen.main.bounds.size.width - 16)
            
            self.subViewHeightConstraint.constant = 88 + self.albumArtistLabelHeightConstraint.constant

            
        } else {
            self.moreButton.setTitle("More", for: .normal)
            
            
            albumArtistLabel.text = self.albumArtistArray[0].title + ", " + self.albumArtistArray[1].title + ", " + self.albumArtistArray[2].title + "..."
            for i in 0..<3 {
                if let attributedText = albumArtistLabel.attributedText?.mutableCopy() as? NSMutableAttributedString {
                    let range = (attributedText.string as NSString).range(of: self.albumArtistArray[i].title)
                    if range.location != NSNotFound {
                        attributedText.addAttributes([
                            .tappableRegion: true,
                            .link:self.albumArtistArray[i].title,
                            .underlineColor : UIColor.clear
                            ], range: range)
                    }
                    albumArtistLabel.attributedText = attributedText
                }
            }
            
            self.albumArtistLabelHeightConstraint.constant = 10
            
            self.subViewHeightConstraint.constant = 88 + self.albumArtistLabelHeightConstraint.constant
        }
        
    }
    
    
    
    // MARK: - Add/Remove Favorite Track
    func addTrackToFavorites(idx:Int) {
        var tmpArray = PreferenceUtils.getFavoriteAudioTracksArray()
        
        let t_Title = self.albumTrackArray[idx].trackTitle
        let t_URL = self.albumTrackArray[idx].trackURL
        let t_ThumbnailImgUrl = self.albumTrackArray[idx].trackThumbnailImageURL
        let t_liked = self.albumTrackArray[idx].trackLiked
        let t_albumname = self.album_title
        tmpArray.append(AlbumDetailInfo.init(trackTitle: t_Title, trackURL: t_URL, trackThumbnailImageURL: t_ThumbnailImgUrl, trackLiked: t_liked, albumName: t_albumname))
        
        PreferenceUtils.setFavoriteAudioTracksArray(array: [])
        PreferenceUtils.setFavoriteAudioTracksArray(array: tmpArray)
    }
    
    func removeTrackToFavorites(idx:Int) {
        var tmpArray = PreferenceUtils.getFavoriteAudioTracksArray()
        
        var removedArray = [AlbumDetailInfo]()
        for i in 0..<tmpArray.count {
            if tmpArray[i].trackURL != self.albumTrackArray[idx].trackURL {
                removedArray.append(tmpArray[i])
            }
        }
        
        PreferenceUtils.setFavoriteAudioTracksArray(array: [])
        PreferenceUtils.setFavoriteAudioTracksArray(array: removedArray)
    }
    
    // MARK: - Show Error
    func showError(erromsg : String){
        SCLAlertView().showError("Error", subTitle:erromsg, closeButtonTitle:"OK")
    }
    
    // MARK: - Request Album Detail
    func requestAlbumDetail() {
        let baseURL = Constants.getAlbumDetailAPI + "?lang=" + UserDefaults.standard.string(forKey: "language")! + "&album_id=" + String(format: "%d", self.album_id)
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
                
                self.albumThumbnailImageUrl = swiftyJsonVar["post"]["thumbnail_images"]["full"]["url"].string!
                
                let titleTmpStr = swiftyJsonVar["post"]["title"].string!
                let attributedString = try? NSAttributedString(data: titleTmpStr.data(using: String.Encoding.unicode)!, options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                    ], documentAttributes: nil)
                
                self.albumTitle = (attributedString?.string)!
                
                self.albumArtist = ""
                for i in 0..<swiftyJsonVar["post"]["taxonomy_artists"].count {
                    if i == 0 {
                        self.albumArtist = swiftyJsonVar["post"]["taxonomy_artists"][i]["title"].string!
                    } else {
                        self.albumArtist = self.albumArtist + " , " + swiftyJsonVar["post"]["taxonomy_artists"][i]["title"].string!
                    }
                    self.albumArtistArray.append(ArtistInfo.init(artist_id: swiftyJsonVar["post"]["taxonomy_artists"][i]["id"].intValue, title: swiftyJsonVar["post"]["taxonomy_artists"][i]["title"].string!, thumbnail: ""))
                }
                
                self.albumCartUrl = swiftyJsonVar["post"]["buttons"].string!
                
                for k in 0..<swiftyJsonVar["post"]["tracks"].count {
                    let trackTitle = swiftyJsonVar["post"]["tracks"][k]["title"].string!
                    let trackUrl = swiftyJsonVar["post"]["tracks"][k]["url"].string!
                    let trackThumbnailImageUrl = swiftyJsonVar["post"]["thumbnail"].string!
                    
                    var trackLiked = false
                    
                    let tempArry = PreferenceUtils.getFavoriteAudioTracksArray()
                    for kk in 0..<tempArry.count {
                        if tempArry[kk].trackURL == trackUrl {
                            trackLiked = true
                        }
                    }
                    
                    let albumName = self.album_title
                    self.albumTrackArray.append(AlbumDetailInfo.init(trackTitle: trackTitle, trackURL: trackUrl, trackThumbnailImageURL: trackThumbnailImageUrl, trackLiked: trackLiked, albumName : albumName))
                }
                self.initUI()
            }else {
                //Hide MBProgress Loading View
                MBProgressHUD.hide(for: self.view, animated: true)
                self.showError(erromsg: "Please check your Network Connection.")
            }
        }
    }
    
    func initUI() {
        addCartButton.isHidden = false
        addFavoriteButton.isHidden = false
        
        self.setThumbnail(imgV: self.thumbnailImageView, urlStr: self.albumThumbnailImageUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        self.albumTitleLabel.text = self.albumTitle
        
        
        albumArtistLabel.text = self.albumArtist
        
        if self.countLabelLines(label: albumArtistLabel) > 1 {
            self.moreButton.isHidden = false
            albumArtistLabel.text = self.albumArtistArray[0].title + ", " + self.albumArtistArray[1].title + ", " + self.albumArtistArray[2].title + "..."
            for i in 0..<3 {
                if let attributedText = albumArtistLabel.attributedText?.mutableCopy() as? NSMutableAttributedString {
                    let range = (attributedText.string as NSString).range(of: self.albumArtistArray[i].title)
                    if range.location != NSNotFound {
                        attributedText.addAttributes([
                            .tappableRegion: true,
                            .link:self.albumArtistArray[i].title,
                            .underlineColor : UIColor.clear
                            ], range: range)
                    }
                    albumArtistLabel.attributedText = attributedText
                }
            }
        } else {
            self.moreButton.isHidden = true
            for i in 0..<self.albumArtistArray.count {
                if let attributedText = albumArtistLabel.attributedText?.mutableCopy() as? NSMutableAttributedString {
                    let range = (attributedText.string as NSString).range(of: self.albumArtistArray[i].title)
                    if range.location != NSNotFound {
                        attributedText.addAttributes([
                            .tappableRegion: true,
                            .link:self.albumArtistArray[i].title,
                            .underlineColor : UIColor.clear
                            ], range: range)
                    }
                    albumArtistLabel.attributedText = attributedText
                }
            }
        }
        
//        self.albumArtistLabelHeightConstraint.constant = heightForView(text: self.albumArtist, font: UIFont.systemFont(ofSize: 14.0), width: UIScreen.main.bounds.size.width - 16)
//
//        self.subViewHeightConstraint.constant = 88 + self.albumArtistLabelHeightConstraint.constant
        tableView.reloadData()
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        if label.frame.height < 59 {
            return 59
        } else {
            return label.frame.height
        }
    }
    
    func countLabelLines(label: UILabel) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = label.text! as NSString
        
        let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: label.font], context: nil)
        
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITableView Delegate & UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumTrackArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell", for: indexPath) as! TrackTableViewCell
        cell.trackTitleLabel.text = self.albumTrackArray[indexPath.row].trackTitle
        self.setThumbnail(imgV: cell.trackThumbnailImageView, urlStr: self.albumTrackArray[indexPath.row].trackThumbnailImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        if self.albumTrackArray[indexPath.row].trackLiked == true {
            cell.likeButton.setImage(UIImage(named: "BtnLiked"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "BtnLike"), for: .normal)
        }
        cell.likeButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playerContainerView.isHidden = false
        playerContainerViewHeightConstraint.constant = 80
        
        PreferenceUtils.setCurrentAudioIndex(num: indexPath.row)
        PreferenceUtils.setCurrentAudioTracksArray(array: [])
        PreferenceUtils.setCurrentAudioTracksArray(array: self.albumTrackArray)
        avPlyerVC?.pauseAudioPlayer()
        avPlyerVC?.prepareAudio()
        avPlyerVC?.playAudio()
        
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
        if segue.identifier == "goWebViewSegue" {
            let cartWebVC = segue.destination as? CartWebViewController
            cartWebVC?.siteURL = self.albumCartUrl
        } else if segue.identifier == "goAVAudioPlayerVCSegue" {
            avPlyerVC = segue.destination as? AVAudioPlayerViewController
        } else if segue.identifier == "goArtistDetailFromAlbumDetailSegue" {
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
    
    // MARK: - ZSWTappableLabelTapDelegate
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedStringKey : Any]) {
        guard let NAME = attributes[.link] as? String else {
            return
        }
        
        print(NAME)
        for i in 0..<self.albumArtistArray.count {
            if NAME == self.albumArtistArray[i].title {
                self.selected_artistID = self.albumArtistArray[i].artist_id
                self.selected_artistTitle = self.albumArtistArray[i].title
            }
        }
        
        self.performSegue(withIdentifier: "goArtistDetailFromAlbumDetailSegue", sender: nil)
    }
    
    
}

