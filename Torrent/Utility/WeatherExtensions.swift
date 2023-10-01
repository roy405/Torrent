//
//  WeatherExtensions.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import Foundation
import CoreData


extension WeatherResponse {
    
    // Convert a CoreData WeatherEntity into a WeatherResponse instance
    init(from entity: WeatherEntity) {
        let location = Location(name: entity.locationName ?? "",
                                region: "",
                                country: "",
                                lat: 0,
                                lon: 0,
                                tz_id: "",
                                localtime_epoch: 0,
                                localtime: "")
        
        let condition = Condition(text: entity.conditionText ?? "",
                                  icon: entity.conditionIconUrl ?? "",
                                  code: 0)
        
        let currentWeather = CurrentWeather(last_updated_epoch: 0,
                                            last_updated: "",
                                            temp_c: entity.temperature,
                                            temp_f: entity.temperature * 9/5 + 32, // Convert Celsius to Fahrenheit
                                            is_day: 1,
                                            condition: condition,
                                            wind_mph: 0,
                                            wind_kph: 0,
                                            wind_degree: 0,
                                            wind_dir: "",
                                            pressure_mb: 0,
                                            pressure_in: 0,
                                            precip_mm: 0,
                                            precip_in: 0,
                                            humidity: 0,
                                            cloud: 0,
                                            feelslike_c: entity.temperature,
                                            feelslike_f: entity.temperature * 9/5 + 32,
                                            vis_km: 0,
                                            vis_miles: 0,
                                            uv: 0,
                                            gust_mph: 0,
                                            gust_kph: 0)
        
        self.init(id: UUID(), location: location, current: currentWeather)
    }
    
    // Save a WeatherResponse instance to CoreData as a WeatherEntity
    func saveToCoreData(context: NSManagedObjectContext) {
        let entity = WeatherEntity(context: context)
        
        entity.locationName = self.location.name
        entity.temperature = self.current.temp_c
        entity.conditionText = self.current.condition.text
        entity.conditionIconUrl = self.current.condition.icon
        
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
    // Fetch the latest WeatherResponse instance from CoreData
    static func fetchFromCoreData(context: NSManagedObjectContext) -> WeatherResponse? {
        let fetchRequest = NSFetchRequest<WeatherEntity>(entityName: "WeatherEntity")
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let firstResult = results.first else { return nil }
            return WeatherResponse(from: firstResult)
        } catch {
            print("Error fetching from Core Data: \(error)")
            return nil
        }
    }
}
