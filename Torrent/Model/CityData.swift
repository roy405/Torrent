//
//  Cities.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import Foundation

// Model for mapping City Data when reading from JSON file (included with Bundle) and then
// retreiving from CoreData after saving.
struct CityData: Codable, Identifiable {
    var id: Int32
    var cityname: String
    var country: String
    var latitude: Double?
    var longitude: Double?

}
