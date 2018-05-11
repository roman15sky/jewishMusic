//
//  Constants.swift
//  JewishMusic.fm
//
//  Created by Admin on 26/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import Foundation

struct Constants {
    
    static let baseURL = "https://jewishmusic.fm/jmusic/albums"
    
    //Get Recent Albums
    static let getRecentAlbumsAPI = baseURL + "/get_recent_albums/"
    
    //Get Artists
    static let getArtistAPI = baseURL + "/get_artists/"
    
    //Get Genres
    static let getGenresAPI = baseURL + "/get_genres/"
    
    //Get Album Detail
    static let getAlbumDetailAPI = baseURL + "/get_album/"
    
    //Get Artist Album
    static let getArtistAlbumAPI = baseURL + "/get_artist/"
    
    //Get Genre Album
    static let getGenreAlbumAPI = baseURL + "/get_genre/"
    
    //Search
    static let searchAPI = baseURL + "/search_all/"
    
    //Track
    static let trackAPI = "https://jewishmusic.fm/wp-content/uploads/secretmusicfolder1"
    
}
