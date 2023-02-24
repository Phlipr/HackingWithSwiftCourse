//
//  Script.swift
//  MyExtension
//
//  Created by Phillip Reynolds on 2/24/23.
//

import Foundation

class Script: NSObject, Codable {
    let scriptText: String
    let scriptName: String
    
    init(scriptText: String, scriptName: String) {
        self.scriptText = scriptText
        self.scriptName = scriptName
    }
}
