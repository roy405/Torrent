//
//  ForecastModel.swift
//  Torrent
//
//  Created by Cube on 10/13/23.
//

import Foundation
// Forecast model to extract data explicitly required for Forecast Functionality
class Forecast {
    var date: Date
    var maxtemp_c: Double
    var mintemp_c: Double
    var conditionText: String

    init(date: Date, maxtemp_c: Double, mintemp_c: Double, conditionText: String) {
        self.date = date
        self.maxtemp_c = maxtemp_c
        self.mintemp_c = mintemp_c
        self.conditionText = conditionText
    }
}

// ForecastLocaiton model to extract data explicitly required for Forecast Funcionlity
class ForecastLocation {
    var name: String
    var region: String
    var country: String
    var lat: Double
    var lon: Double

    init(name: String, region: String, country: String, lat: Double, lon: Double) {
        self.name = name
        self.region = region
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}


