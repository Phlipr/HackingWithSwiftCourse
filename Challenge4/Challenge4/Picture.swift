//
//  Picture.swift
//  Challenge4
//
//  Created by Phillip Reynolds on 12/20/22.
//

import UIKit

class Picture: NSObject, Codable {
    var caption: String
    var image: String
    
    init(caption: String, image: String) {
        self.caption = caption
        self.image = image
    }
}
