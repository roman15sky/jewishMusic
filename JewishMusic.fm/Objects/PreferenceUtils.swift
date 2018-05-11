//
//  PreferenceUtils.swift
//  JewishMusic.fm
//
//  Created by Admin on 05/05/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import Foundation

class PreferenceUtils {
    
    static let preferences = UserDefaults.standard
    
    static let CURRENT_AUDIO_INDEX = "CURRENT_AUDIO_INDEX"
    static let CURRENT_AUDIO_TRACKS_ARRAY = "CURRENT_AUDIO_TRACKS_ARRAY"
    static let FAVORITE_AUDIO_TRACKS_ARRAY = "FAVORITE_AUDIO_TRACKS_ARRAY"
    
    static func setCurrentAudioIndex(num:Int) {
        preferences.set(num, forKey: CURRENT_AUDIO_INDEX)
        preferences.synchronize()
    }
    
    static func getCurrentAudioIndex()-> Int{
        return preferences.integer(forKey: CURRENT_AUDIO_INDEX)
    }
    
    
    static func setCurrentAudioTracksArray (array : [AlbumDetailInfo]) {
        preferences.setValue(NSKeyedArchiver.archivedData(withRootObject: array), forKey: CURRENT_AUDIO_TRACKS_ARRAY)
        preferences.synchronize()
    }
    
    static func getCurrentAudioTracksArray() -> [AlbumDetailInfo] {
        let placesData = UserDefaults.standard.object(forKey: CURRENT_AUDIO_TRACKS_ARRAY) as? NSData
        if placesData == nil {
            return []
        } else {
            return (NSKeyedUnarchiver.unarchiveObject(with: placesData! as Data) as? [AlbumDetailInfo])!
        }
    }
    
    
    static func setFavoriteAudioTracksArray (array : [AlbumDetailInfo]) {
        preferences.setValue(NSKeyedArchiver.archivedData(withRootObject: array), forKey: FAVORITE_AUDIO_TRACKS_ARRAY)
        preferences.synchronize()
    }
    
    static func getFavoriteAudioTracksArray() -> [AlbumDetailInfo] {
        let placesData = UserDefaults.standard.object(forKey: FAVORITE_AUDIO_TRACKS_ARRAY) as? NSData
        if placesData == nil {
            return []
        } else {
            return (NSKeyedUnarchiver.unarchiveObject(with: placesData! as Data) as? [AlbumDetailInfo])!
        }
    }
    
}
