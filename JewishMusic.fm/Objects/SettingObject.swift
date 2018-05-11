//
//  SettingObject.swift
//  JewishMusic.fm
//
//  Created by Admin on 05/05/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import Foundation

class SettingObject: NSObject {
    
    var titleStr : String
    var describeStr : String
    
    init(titleStr: String, describeStr: String) {
        self.titleStr = titleStr
        self.describeStr = describeStr
    }
    
}
