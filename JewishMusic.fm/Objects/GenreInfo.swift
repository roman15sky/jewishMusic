//
//  GenreInfo.swift
//  JewishMusic.fm
//
//  Created by Admin on 27/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import Foundation
class GenreInfo: NSObject {
    
    var genre_id : String
    var name : String
    var count_of_albums : String
    
    init(genre_id: String, name: String, count_of_albums : String) {
        self.genre_id = genre_id
        self.name = name
        self.count_of_albums = count_of_albums
    }
    
}
