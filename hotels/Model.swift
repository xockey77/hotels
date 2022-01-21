//
//  Model.swift
//  hotels
//
//  Created by username on 20.12.2021.
//

import Foundation

struct Hotel: Decodable {
    var id: Int = 0
    var name: String = ""
    var address: String = ""
    var stars: Double = 0.0
    var distance: Double = 0.0
    var image: String?
    var suites_availability: String = ""
    var suitesCount: Int?
    var lat: Double?
    var lon: Double?
}
