//
//  Persistence.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Torrent")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error, maybe notify the user or recover
                print("Error loading persistent stores: \(error), \(error.userInfo)")
            } else {
                print("Persistent store loaded successfully.")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveCitiesToCoreData(cities: [CityData]) {
        let context = container.newBackgroundContext() // Use background context
        context.perform {
            for city in cities {
                let cityEntity = CityEntity(context: context)
                cityEntity.id = city.id
                cityEntity.cityname = city.cityname // Notice change in attribute name
                cityEntity.country = city.country
                cityEntity.longitude = city.longitude ?? 0.0
                cityEntity.latitude = city.latitude ?? 0.0
            }

            if context.hasChanges { // Check if there are changes before saving
                do {
                    try context.save()
                    print("Successfully saved \(cities.count) cities to Core Data.")
                } catch let error as NSError {
                    // Handle the error, maybe notify the user or recover
                    print("Could not save city. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func saveRecommendationToCoreData(recommendation: Recommendation) {
        let context = container.newBackgroundContext() // Use background context
        context.perform {
            let recommendationEntity = RecommendationEntity(context: context)
            recommendationEntity.id = recommendation.id
            recommendationEntity.dateAndTime = recommendation.dateAndTime
            recommendationEntity.recommendation = recommendation.recommendation
            recommendationEntity.weatherCondition = recommendation.weatherCondition
            
            if context.hasChanges { // Check if there are changes before saving
                do {
                    try context.save()
                    print("Successfully saved recommendation to Core Data.")
                } catch let error as NSError {
                    // Handle the error, maybe notify the user or recover
                    print("Could not save recommendation. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func fetchRecommendations() -> [Recommendation] {
        let fetchRequest = NSFetchRequest<RecommendationEntity>(entityName: "RecommendationEntity")
        
        do {
            let cdRecommendations = try container.viewContext.fetch(fetchRequest)
            return cdRecommendations.map {
                Recommendation(
                    id: $0.id!,
                    dateAndTime: $0.dateAndTime!,
                    recommendation: $0.recommendation!,
                    weatherCondition: $0.weatherCondition!
                )
            }
        } catch {
            print("Failed fetching recommendations: \(error)")
            return []
        }
    }
    
    func fetchRecommendationsForToday() -> [Recommendation] {
           let currentDate = Date()
           let fetchRequest = NSFetchRequest<RecommendationEntity>(entityName: "RecommendationEntity")
           fetchRequest.predicate = NSPredicate(format: "(%@ <= dateAndTime) AND (dateAndTime < %@)",
                                                argumentArray: [currentDate.startOfDay, currentDate.endOfDay])
           
           do {
               let cdRecommendations = try container.viewContext.fetch(fetchRequest)
               return cdRecommendations.map {
                   Recommendation(
                       id: $0.id!,
                       dateAndTime: $0.dateAndTime!,
                       recommendation: $0.recommendation!,
                       weatherCondition: $0.weatherCondition!
                   )
               }
           } catch {
               print("Failed fetching today's recommendations: \(error)")
               return []
           }
       }
       
       // Additional utility functions to get start and end of the day for a given date.
    
    func hasCities() -> Bool {
        let fetchRequest: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        let count = try? container.viewContext.count(for: fetchRequest)
        return (count ?? 0) > 0
    }
    
    func fetchCurrentWeather() -> CurrentWeatherEntity? {
        let fetchRequest: NSFetchRequest<CurrentWeatherEntity> = CurrentWeatherEntity.fetchRequest()
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch current weather from Core Data: \(error)")
            return nil
        }
    }
    
    func saveOrUpdateCurrentWeather(from model: CurrentWeatherModel) {
        let context = container.newBackgroundContext() // Using a background context for saving
        context.perform {
            if let existingWeather = self.fetchCurrentWeather() {
                existingWeather.temperature = model.temperature
                existingWeather.conditionText = model.conditionText
                existingWeather.conditionIconURL = model.conditionIconURL
                existingWeather.location = model.location
            } else {
                let newWeather = CurrentWeatherEntity(context: context)
                newWeather.temperature = model.temperature
                newWeather.conditionText = model.conditionText
                newWeather.conditionIconURL = model.conditionIconURL
                newWeather.location = model.location
            }
            
            if context.hasChanges { // Check if there are changes before saving
                do {
                    try context.save()
                    print("Successfully saved or updated current weather to Core Data.")
                } catch let error as NSError {
                    print("Could not save or update current weather. \(error), \(error.userInfo)")
                }
            }
        }
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

