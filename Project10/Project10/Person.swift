//
//  Person.swift
//  Project10
//
//  Created by Phillip Reynolds on 12/9/22.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}