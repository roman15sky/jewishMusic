//
//  FavoritesViewController.swift
//  JewishMusic.fm
//
//  Created by Admin on 26/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit
import FAPanels
import GoogleMobileAds

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, GADInterstitialDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var containerViewHeightContraint: NSLayoutConstraint!
    
    var favoriteTracksArray = [AlbumDetailInfo]()
    var avPlyerVC : AVAudioPlayerViewController?
    
    
    @IBOutlet var advertisingView: UIView!
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-2132873164239431/5622245664"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    var interstitial: GADInterstitial?
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2132873164239431/5802085353")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // Remove the following line before you upload the app
        request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adBannerView.load(GADRequest())
        interstitial = createAndLoadInterstitial()
        
        titleLabel.text = "Favorites".localized(lang: UserDefaults.standard.string(forKey: "language")!)
        // Do any additional setup after loading the view.
        favoriteTracksArray = PreferenceUtils.getFavoriteAudioTracksArray()
        tableView.reloadData()
        
        if AudioPlayer.sharedInstance.player.isPlaying {
            containerView.isHidden = false
            containerViewHeightContraint.constant = 80
        } else {
            containerView.isHidden = true
            containerViewHeightContraint.constant = 0
        }
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
        favoriteTracksArray = []
        favoriteTracksArray = PreferenceUtils.getFavoriteAudioTracksArray()
        self.tableView.reloadData()
    }
    
    @IBAction func onDelete(_ sender: Any) {
        PreferenceUtils.setFavoriteAudioTracksArray(array: [])
        favoriteTracksArray = PreferenceUtils.getFavoriteAudioTracksArray()
        self.tableView.reloadData()
    }
    
    @IBAction func onPlayList(_ sender: Any) {
        containerView.isHidden = false
        containerViewHeightContraint.constant = 80
        
        PreferenceUtils.setCurrentAudioIndex(num: 0)
        PreferenceUtils.setCurrentAudioTracksArray(array: [])
        PreferenceUtils.setCurrentAudioTracksArray(array: self.favoriteTracksArray)
        avPlyerVC?.pauseAudioPlayer()
        avPlyerVC?.prepareAudio()
        avPlyerVC?.playAudio()
    }
    
    @IBAction func onLike(_ sender: UIButton) {
        if self.favoriteTracksArray[sender.tag].trackLiked == true {
            sender.setImage(UIImage(named: "BtnLike"), for: .normal)
            self.favoriteTracksArray[sender.tag].trackLiked = false
            self.removeTrackToFavorites(idx: sender.tag)
        } else {
            sender.setImage(UIImage(named: "BtnLiked"), for: .normal)
            self.favoriteTracksArray[sender.tag].trackLiked = true
            self.addTrackToFavorites(idx: sender.tag)
        }
    }
    
    
    // MARK: - Add/Remove Favorite Track
    func addTrackToFavorites(idx:Int) {
        var tmpArray = PreferenceUtils.getFavoriteAudioTracksArray()
        
        let t_Title = self.favoriteTracksArray[idx].trackTitle
        let t_URL = self.favoriteTracksArray[idx].trackURL
        let t_ThumbnailImgUrl = self.favoriteTracksArray[idx].trackThumbnailImageURL
        let t_liked = self.favoriteTracksArray[idx].trackLiked
        let t_albumName = self.favoriteTracksArray[idx].albumName
        
        tmpArray.append(AlbumDetailInfo.init(trackTitle: t_Title, trackURL: t_URL, trackThumbnailImageURL: t_ThumbnailImgUrl, trackLiked: t_liked, albumName: t_albumName))
        
        PreferenceUtils.setFavoriteAudioTracksArray(array: [])
        PreferenceUtils.setFavoriteAudioTracksArray(array: tmpArray)
    }
    
    func removeTrackToFavorites(idx:Int) {
        var tmpArray = PreferenceUtils.getFavoriteAudioTracksArray()
        
        var removedArray = [AlbumDetailInfo]()
        for i in 0..<tmpArray.count {
            if tmpArray[i].trackURL != self.favoriteTracksArray[idx].trackURL {
                removedArray.append(tmpArray[i])
            }
        }
        
        PreferenceUtils.setFavoriteAudioTracksArray(array: [])
        PreferenceUtils.setFavoriteAudioTracksArray(array: removedArray)
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
        return self.favoriteTracksArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell", for: indexPath) as! TrackTableViewCell
        cell.trackTitleLabel.text = self.favoriteTracksArray[indexPath.row].trackTitle
        self.setThumbnail(imgV: cell.trackThumbnailImageView, urlStr: self.favoriteTracksArray[indexPath.row].trackThumbnailImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        if self.favoriteTracksArray[indexPath.row].trackLiked == true {
            cell.likeButton.setImage(UIImage(named: "BtnLiked"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "BtnLike"), for: .normal)
        }
        cell.likeButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        containerView.isHidden = false
        containerViewHeightContraint.constant = 80
        
        PreferenceUtils.setCurrentAudioIndex(num: indexPath.row)
        PreferenceUtils.setCurrentAudioTracksArray(array: [])
        PreferenceUtils.setCurrentAudioTracksArray(array: self.favoriteTracksArray)
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
        if segue.identifier == "goEmbededAudioPlayerSegue" {
            avPlyerVC = segue.destination as? AVAudioPlayerViewController
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
    
    //MARK: - GADInterstitial Delegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial loaded successfully")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
}
