//
//  AlbumInfo.swift
//  JewishMusic.fm
//
//  Created by Admin on 26/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import Foundation

class AlbumInfo: NSObject {
    
    var album_id : Int
    var title : String
    var thumbnail_images : String
    var taxonomy_artists = [String]()
    
    
    init(album_id: Int, title: String, thumbnail_images : String, taxonomy_artists : [String]) {
        self.album_id = album_id
        self.title = title
        self.thumbnail_images = thumbnail_images
        self.taxonomy_artists = taxonomy_artists.map { $0.copy() } as! [String]
    }
    
}
