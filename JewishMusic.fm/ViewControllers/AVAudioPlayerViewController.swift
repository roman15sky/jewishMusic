//
//  AVAudioPlayerViewController.swift
//  JewishMusic.fm
//
//  Created by Admin on 03/05/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AVAudioPlayerViewController: UIViewController {
    
    @IBOutlet var audioView: UIView!
    @IBOutlet var audioImageView: UIImageView!
    @IBOutlet var audioTitleLabel: UILabel!
    @IBOutlet var audioSlider: UISlider!
    @IBOutlet var audioCurrentTimeLabel: UILabel!
    @IBOutlet var audioMaxiumTimeLabel: UILabel!
    @IBOutlet var audioPlayButton: UIButton!
    @IBOutlet var audioNextButton: UIButton!
    @IBOutlet var audioPreviousButton: UIButton!
    
    private var audioLength = 0.0
    private var totalLengthOfAudio = ""
    private var timer:Timer!
    private var currentAudioURLStr = ""
    
    
    private var timerAgain:Timer!
    private var isdownloading = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.audioView.layer.borderWidth = 1
        isdownloading = false
        
        if AudioPlayer.sharedInstance.player.isPlaying {
            print(AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds)
            self.initUI()
            self.startTimerAgain()
        }
    }

    func initUI() {
        let tmpArry = PreferenceUtils.getCurrentAudioTracksArray()
        let tmpIndx = PreferenceUtils.getCurrentAudioIndex()
        
        self.setThumbnail(imgV: self.audioImageView, urlStr: tmpArry[tmpIndx].trackThumbnailImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        self.audioTitleLabel.text = tmpArry[tmpIndx].trackTitle
        
        let timemax = calculateTimeFromNSTimeInterval(CMTimeGetSeconds((AudioPlayer.sharedInstance.player.currentItem?.asset.duration)!))
        self.audioMaxiumTimeLabel.text = "\(timemax.minute):\(timemax.second)"
        
        DispatchQueue.main.async {
            self.audioSlider.maximumValue = CFloat(CMTimeGetSeconds((AudioPlayer.sharedInstance.player.currentItem?.asset.duration)!))
            self.audioSlider.minimumValue = 0.0
            self.audioSlider.value = CFloat(AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds)
        }
        
        self.audioPlayButton.setImage(UIImage(named: "BtnPause"), for: .normal)
    }
    
    func startTimerAgain(){
        if timerAgain == nil {
            timerAgain = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AVAudioPlayerViewController.updateAgain(_:)), userInfo: nil,repeats: true)
            timerAgain.fire()
        }
    }
    
    @objc func updateAgain(_ timer: Timer){
        if timerAgain == nil {
            return
        }
        let time = calculateTimeFromNSTimeInterval(AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds)
        self.audioCurrentTimeLabel.text = "\(time.minute):\(time.second)"
        self.audioSlider.value = CFloat(AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UISlider Method
    @IBAction func audioSliderChanged(_ sender: UISlider) {
        let selectedValue = CMTime(seconds: Double(sender.value), preferredTimescale: 1)
        
        AudioPlayer.sharedInstance.player.seek(to: selectedValue)
        
        if MPNowPlayingInfoCenter.default().nowPlayingInfo != nil {
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds
        }
        
    }
    
    // MARK: - Button Actions
    @IBAction func onPlayButton(_ sender: Any) {
        if AudioPlayer.sharedInstance.player.isPlaying {
            self.pauseAudioPlayer()
            self.audioPlayButton.setImage(UIImage(named: "BtnPlay"), for: .normal)
        } else {
            self.playAudio()
            self.audioPlayButton.setImage(UIImage(named: "BtnPause"), for: .normal)
        }
    }
    
    @IBAction func onNextButton(_ sender: Any) {
        self.pauseAudioPlayer()
        self.playNextAudio()
    }
    
    @IBAction func onPreviousButton(_ sender: Any) {
        self.pauseAudioPlayer()
        self.playPreviousAudio()
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

    func setRemoteThumbnail(urlStr : String, albumname : String) {
        getDataFromUrl(url: URL(string: urlStr)!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)!
                let albumArt = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                    return image
                })
                let albumDict = [MPMediaItemPropertyTitle: self.audioTitleLabel.text!,MPMediaItemPropertyAlbumTitle:albumname, MPNowPlayingInfoPropertyPlaybackRate:1, MPMediaItemPropertyPlaybackDuration: CFloat(CMTimeGetSeconds((AudioPlayer.sharedInstance.player.currentItem?.asset.duration)!)), MPMediaItemPropertyArtwork: albumArt, MPNowPlayingInfoPropertyElapsedPlaybackTime:AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds] as [String : Any]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = albumDict
                
            }
        }
    }
    
    
    // MARK: - Prepare Audio
    func prepareAudio() {
        isdownloading = true
//        do {
//            //keep alive audio at background
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        } catch _ {
//        }
//        do {
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch _ {
//        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print(error)
        }
        
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(AVAudioPlayerViewController.playPreviousAudio))
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(AVAudioPlayerViewController.playNextAudio))
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(AVAudioPlayerViewController.playAudio))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(AVAudioPlayerViewController.pauseAudioPlayer))
        
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.skipForwardCommand.isEnabled = false
        
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget(self, action: #selector(AVAudioPlayerViewController.pauseAudioPlayer))
        
        
        //Init Image & Title & Slider
        let tmpArry = PreferenceUtils.getCurrentAudioTracksArray()
        let tmpIndx = PreferenceUtils.getCurrentAudioIndex()
        
        self.setThumbnail(imgV: self.audioImageView, urlStr: tmpArry[tmpIndx].trackThumbnailImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        self.audioTitleLabel.text = tmpArry[tmpIndx].trackTitle
        self.audioSlider.value = 0.0
        
        //Get Audio URL String
        self.currentAudioURLStr = Constants.trackAPI + tmpArry[tmpIndx].trackURL
        
        //Init AVPlayer
        let playerItem = AVPlayerItem.init(url: URL.init(string:currentAudioURLStr)!)
        AudioPlayer.sharedInstance.player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: AudioPlayer.sharedInstance.player)
        playerLayer.frame = self.audioView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.audioView.layer.addSublayer(playerLayer)
        
        //Get Audio Length
        audioLength = CMTimeGetSeconds((AudioPlayer.sharedInstance.player.currentItem?.asset.duration)!)
        
        //Init Slider Values MAX & MIN & CURRENT
        DispatchQueue.main.async {
            self.audioSlider.maximumValue = CFloat(CMTimeGetSeconds((AudioPlayer.sharedInstance.player.currentItem?.asset.duration)!))
            self.audioSlider.minimumValue = 0.0
            self.audioSlider.value = 0.0
        }
        
        //Init Time Label Text
        showTotalSongLength()
        self.audioCurrentTimeLabel.text = "00:00"
        
        //Add Observer to AVPLAYER
        NotificationCenter.default.addObserver(self, selector: #selector(AVAudioPlayerViewController.finishAudioPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        
        //Add Remote Info
        self.setRemoteThumbnail(urlStr: tmpArry[tmpIndx].trackThumbnailImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!, albumname: tmpArry[tmpIndx].albumName)
    }
    
    // MARK: - Timer
    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AVAudioPlayerViewController.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    func stopTimer(){
        timer.invalidate()
    }
    
    @objc func update(_ timer: Timer){
        if !AudioPlayer.sharedInstance.player.isPlaying {
            return
        }
        let time = calculateTimeFromNSTimeInterval(AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds)
        self.audioCurrentTimeLabel.text = "\(time.minute):\(time.second)"
        self.audioSlider.value = CFloat(AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds)
    }
    
    
    // MARK: - CalculateTimeForMinutesAndSeconds
    func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
        // let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        // var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    
    
    // MARK: - Time Label
    func showTotalSongLength(){
        calculateSongLength()
        self.audioMaxiumTimeLabel.text = totalLengthOfAudio
    }
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }
    
    
    // MARK: - Observer for FinishAudioPlaying
    @objc func finishAudioPlaying()
    {
        NotificationCenter.default.removeObserver(self)
        print("Video Finished")
        self.pauseAudioPlayer()
        self.playNextAudio()
    }
    
    // MARK: - Audio Controls
    //MARK: - Play Audio
    @objc func playAudio() {
        self.audioPlayButton.setImage(UIImage(named: "BtnPause"), for: .normal)
        AudioPlayer.sharedInstance.player.play()
        isdownloading = false
        startTimer()
        
        if MPNowPlayingInfoCenter.default().nowPlayingInfo != nil {
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds
        }
    }
    
    @objc func pauseAudioPlayer(){
        self.audioPlayButton.setImage(UIImage(named: "BtnPlay"), for: .normal)
        AudioPlayer.sharedInstance.player.pause()
        
        if MPNowPlayingInfoCenter.default().nowPlayingInfo != nil {
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 0
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = AudioPlayer.sharedInstance.player.currentItem!.currentTime().seconds
        }
    }
    
    @objc func playNextAudio(){
        if isdownloading {
            return
        }
        pauseAudioPlayer()
        var currentAudioIndex = PreferenceUtils.getCurrentAudioIndex()
        currentAudioIndex += 1
        if currentAudioIndex > PreferenceUtils.getCurrentAudioTracksArray().count-1 {
            currentAudioIndex = 0
        }
        PreferenceUtils.setCurrentAudioIndex(num: currentAudioIndex)
        prepareAudio()
        playAudio()
    }
    
    @objc func playPreviousAudio(){
        if isdownloading {
            return
        }
        pauseAudioPlayer()
        var currentAudioIndex = PreferenceUtils.getCurrentAudioIndex()
        currentAudioIndex -= 1
        if currentAudioIndex < 0 {
            currentAudioIndex = PreferenceUtils.getCurrentAudioTracksArray().count-1
        }
        PreferenceUtils.setCurrentAudioIndex(num: currentAudioIndex)
        prepareAudio()
        playAudio()
        
    }
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

