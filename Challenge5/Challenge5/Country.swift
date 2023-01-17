//
//  Country.swift
//  Challenge5
//
//  Created by Phillip Reynolds on 1/16/23.
//

import Foundation

struct Country: Decodable {
    let name: String
    let capital: String?
    let population: Int?
    let area: Float?
    let currencies: [Currency]?
    let independent: Bool?
}
