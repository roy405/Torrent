//
//  RecentWeather.swift
//  Torrent
//
//  Created by Cube on 9/28/23.
//

import Foundation

// RecentWeather model used to map the recent weather data for each city type selected and displayed in a list
struct RecentWeather: Identifiable, Hashable{
    var id: UUID?
    var cityName: String
    var countryName: String
    var temperature: Double
    var conditionText: String
    var iconURL: String
    var longitude: Double
    var latitude: Double
    
    init(recentWeatherEntity: RecentWeatherEntity) {
        self.id = recentWeatherEntity.id!
        self.cityName = recentWeatherEntity.city ?? ""
        self.countryName = recentWeatherEntity.country ?? ""
        self.temperature = recentWeatherEntity.temperature
        self.conditionText = recentWeatherEntity.conditionText ?? ""
        self.iconURL = recentWeatherEntity.iconURL ?? ""
        self.longitude = recentWeatherEntity.longitude 
        self.latitude = recentWeatherEntity.latitude 
    }
}
