//
//  AlbumDetailInfo.swift
//  JewishMusic.fm
//
//  Created by Admin on 27/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import Foundation

class AlbumDetailInfo: NSObject, NSCoding {
    
    var trackTitle : String
    var trackURL : String
    var trackThumbnailImageURL : String
    var trackLiked : Bool
    var albumName : String
    
    init(trackTitle: String, trackURL : String, trackThumbnailImageURL : String, trackLiked : Bool, albumName:String) {
        self.trackTitle = trackTitle
        self.trackURL = trackURL
        self.trackThumbnailImageURL = trackThumbnailImageURL
        self.trackLiked = trackLiked
        self.albumName = albumName
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let trackTitle = aDecoder.decodeObject(forKey: "trackTitle") as! String
        let trackURL = aDecoder.decodeObject(forKey: "trackURL") as! String
        let trackThumbnailImageURL = aDecoder.decodeObject(forKey: "trackThumbnailImageURL") as! String
        let trackLiked = aDecoder.decodeBool(forKey: "trackLiked")
        let albumName = aDecoder.decodeObject(forKey: "albumName") as! String
        self.init(trackTitle: trackTitle, trackURL: trackURL, trackThumbnailImageURL: trackThumbnailImageURL, trackLiked: trackLiked, albumName:albumName)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackTitle, forKey: "trackTitle")
        aCoder.encode(trackURL, forKey: "trackURL")
        aCoder.encode(trackThumbnailImageURL, forKey: "trackThumbnailImageURL")
        aCoder.encode(trackLiked, forKey: "trackLiked")
        aCoder.encode(albumName, forKey: "albumName")
    }
    
}
