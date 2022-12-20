//
//  Picture.swift
//  Project1
//
//  Created by Phillip Reynolds on 12/16/22.
//

import UIKit

class Picture: NSObject, Codable {
    var fileName: String
    var accessCount: Int = 0
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    func incrementAccessCount() {
        self.accessCount += 1
    }
}
