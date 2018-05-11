//
//  AudioPlayer.swift
//  JewishMusic.fm
//
//  Created by Admin on 04/05/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayer {
    static let sharedInstance = AudioPlayer()
    
    var player:AVPlayer = AVPlayer()
}
