//
//  CurrentWeatherModel.swift
//  Torrent
//
//  Created by Cube on 10/2/23.
//

import Foundation

// Current Weather Model to map Current Weather data
// This is a separate Model from the API where data is filtered as required
struct CurrentWeatherModel {
    public var temperature: Double
    public var conditionText: String
    public var conditionIconURL: String
    public var location: String
}
