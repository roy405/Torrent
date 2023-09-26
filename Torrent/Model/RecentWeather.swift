//
//  RecentWeather.swift
//  Torrent
//
//  Created by Cube on 9/28/23.
//

import Foundation

struct RecentWeather: Identifiable, Hashable{
    var id: UUID?
    var cityName: String
    var countryName: String
    var temperature: Double
    var conditionText: String
    var iconURL: String
    
    init(recentWeatherEntity: RecentWeatherEntity) {
        self.id = recentWeatherEntity.id!
        self.cityName = recentWeatherEntity.city ?? ""
        self.countryName = recentWeatherEntity.country ?? ""
        self.temperature = recentWeatherEntity.temperature
        self.conditionText = recentWeatherEntity.conditionText ?? ""
        self.iconURL = recentWeatherEntity.iconURL ?? ""
    }
}
