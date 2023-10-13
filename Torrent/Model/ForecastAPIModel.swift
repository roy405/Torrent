//
//  ForecastAPIModel.swift
//  Torrent
//
//  Created by Cube on 10/13/23.
//

import Foundation

// Model to map API data
struct ForecastAPIModel: Codable {
    let location: Location
    let forecast: ForecastDays

    struct Location: Codable {
        let name: String
        let region: String
        let country: String
        let lat: Double
        let lon: Double
    }

    struct ForecastDays: Codable {
        let forecastday: [DayForecast]
    }
    
    struct DayForecast: Codable {
        let date: String
        let day: DayDetails

        struct DayDetails: Codable {
            let maxtemp_c: Double
            let mintemp_c: Double
            let condition: Condition

            struct Condition: Codable {
                let text: String
            }
        }
    }
}

