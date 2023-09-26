//
//  Cities.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import Foundation

struct CityData: Codable, Identifiable{
    var id: Int32
    var cityname: String
    var country: String
    var latitude: Double?
    var longitude: Double?
}

