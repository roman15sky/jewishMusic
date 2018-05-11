//
//  ArtistInfo.swift
//  JewishMusic.fm
//
//  Created by Admin on 27/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import Foundation
class ArtistInfo: NSObject {
    
    var artist_id : Int
    var title : String
    var thumbnail : String
    
    init(artist_id: Int, title: String, thumbnail : String) {
        self.artist_id = artist_id
        self.title = title
        self.thumbnail = thumbnail
    }
    
}
