//
//  WeatherDataModel.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import Foundation

// Decodable Weather Response to capture data without UUID
struct DecodableWeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
}

// For the requirement of List views, requires an UUID
struct WeatherResponse: Codable, Identifiable{
    let id: UUID
    let location: Location
    let current: CurrentWeather
}

// The Location Model fetched from API
struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tz_id: String
    let localtime_epoch: Int
    let localtime: String
}

// The CurrentWeather Model fetched from API
struct CurrentWeather: Codable {
    let last_updated_epoch: Int
    let last_updated: String
    let temp_c: Double
    let temp_f: Double
    let is_day: Int
    let condition: Condition
    let wind_mph: Double
    let wind_kph: Double
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Double
    let pressure_in: Double
    let precip_mm: Double
    let precip_in: Double
    let humidity: Int
    let cloud: Int
    let feelslike_c: Double
    let feelslike_f: Double
    let vis_km: Double
    let vis_miles: Double
    let uv: Double
    let gust_mph: Double
    let gust_kph: Double
}

// The Condition Model fetched from API
struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}
