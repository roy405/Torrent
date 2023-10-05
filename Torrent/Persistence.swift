//
//  Persistence.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import CoreData

// Central Persistence Controller to interface with Core Data
struct PersistenceController {
    // Shared instance of the PersistenceController for singleton access.
    static let shared = PersistenceController()
    
    // Container for the Core Data stack.
    let container: NSPersistentCloudKitContainer
    
    // Initializer for Persistence class
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Torrent")
        if inMemory {
            // If inMemory flag is set, data will not be saved to disk.
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
    
    // Func to save all cities extracted from JSON to Core Data
    func saveCitiesToCoreData(_ cities: [CityData]) -> Result<Void, Error> {
        let context = container.newBackgroundContext()
        var result: Result<Void, Error> = .success(())
        
        context.performAndWait { // using performAndWait to ensure that result is set before the function returns
            for city in cities {
                let cityEntity = CityEntity(context: context)
                cityEntity.id = city.id
                cityEntity.cityname = city.cityname
                cityEntity.country = city.country
                cityEntity.latitude = city.latitude ?? 0.0
                cityEntity.longitude = city.longitude ?? 0.0
            }
            if context.hasChanges {
                do {
                    try context.save()
                    print("Successfully saved \(cities.count) cities to Core Data.")
                } catch {
                    print("Could not save cities. \(error)")
                    result = .failure(CoreDataError.citySaveError)
                }
            }
        }
        return result
    }
    
    // Fetch all Cities data from Core Data
    func fetchCities() -> Result<[CityData], Error> {
        let fetchRequest: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        
        do {
            let fetchedCities = try container.viewContext.fetch(fetchRequest)
            let cities = fetchedCities.map {
                CityData(id: $0.id,
                         cityname: $0.cityname ?? "",
                         country: $0.country ?? "",
                         latitude: $0.latitude,
                         longitude: $0.longitude)
            }
            return .success(cities)
        } catch {
            print("Failed fetching cities: \(error)")
            return .failure(CoreDataError.cityFetchError)
        }
    }
    
    // Fetches all Recent Weather for selected cities from Core Data
    func fetchAllWeatherBySelectCity() -> Result<[RecentWeatherEntity], Error> {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<RecentWeatherEntity> = RecentWeatherEntity.fetchRequest()
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            return .success(fetchedResults)
        } catch {
            print("Error fetching recent weather from Core Data: \(error)")
            return .failure(CoreDataError.recentWeatherForCityFetchError)
        }
    }
    
    // Deletes a Recent Weather for a selected city from Core Data
    func deleteWeatherByCity(withID id: UUID) -> Result<Void, Error> {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecentWeatherEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            return .success(())
        } catch {
            print("Error deleting weather: \(error)")
            return .failure(CoreDataError.recentWeatherForCityDeleteError)
        }
    }

    

    // Saves a single recommendation to CoreData.
    func saveRecommendationToCoreData(recommendation: Recommendation) -> Result<Void, Error> {
        let context = container.newBackgroundContext()
        var result: Result<Void, Error> = .success(())
        
        context.performAndWait {
            let recommendationEntity = RecommendationEntity(context: context)
            recommendationEntity.id = recommendation.id
            recommendationEntity.dateAndTime = recommendation.dateAndTime
            recommendationEntity.recommendation = recommendation.recommendation
            recommendationEntity.weatherCondition = recommendation.weatherCondition
            
            if context.hasChanges {
                do {
                    try context.save()
                    print("Successfully saved recommendation to Core Data.")
                } catch {
                    print("Could not save recommendation. \(error)")
                    result = .failure(CoreDataError.recommendationSaveError)
                }
            }
        }
        
        return result
    }
    
    
    // Fetches only today's recommendations from Core Data.
    func fetchRecommendationsForToday() -> Result<[Recommendation], Error> {
        let currentDate = Date()
        let fetchRequest = NSFetchRequest<RecommendationEntity>(entityName: "RecommendationEntity")
        fetchRequest.predicate = NSPredicate(format: "(%@ <= dateAndTime) AND (dateAndTime < %@)",
                                             argumentArray: [currentDate.startOfDay, currentDate.endOfDay])
        
        do {
            let cdRecommendations = try container.viewContext.fetch(fetchRequest)
            let recommendations = cdRecommendations.map {
                Recommendation(
                    id: $0.id!,
                    dateAndTime: $0.dateAndTime!,
                    recommendation: $0.recommendation!,
                    weatherCondition: $0.weatherCondition!
                )
            }
            return .success(recommendations)
        } catch {
            print("Failed fetching today's recommendations: \(error)")
            return .failure(CoreDataError.recommendationFetchError)
        }
    }
    
    
    
    
    // fetches a single instance of the current weather from core data
    func fetchCurrentWeather() -> Result<CurrentWeatherEntity?, Error> {
        let fetchRequest: NSFetchRequest<CurrentWeatherEntity> = CurrentWeatherEntity.fetchRequest()
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            return .success(results.first)
        } catch {
            print("Failed to fetch current weather from Core Data: \(error)")
            return .failure(CoreDataError.currentWeatherFetchError)
        }
    }
    
    // If Current Weather is non existent: saves and creates a record.
    // If Current Weather is exisitent: updates the current weather to CoreData.
    // Hence always maintaining one single record of current weather.
    func saveOrUpdateCurrentWeather(from model: CurrentWeatherModel) -> Result<Void, Error> {
        let context = container.newBackgroundContext() // Using a background context for saving
        var result: Result<Void, Error> = .success(())
        
        context.performAndWait { // using performAndWait to ensure that result is set before the function returns
            if let existingWeather = try? self.fetchCurrentWeather().get() { // handle the Result from fetchCurrentWeather
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
                } catch {
                    print("Could not save or update current weather. \(error)")
                    result = .failure(CoreDataError.currentWeatherSaveOrUpdateError)
                }
            }
        }
        return result
    }
    
    // Saves a single instance of feedback to CoreData
    func saveFeedbackToCoreData(feedback: FeedbackModel) -> Result<Void, Error> {
        let context = container.newBackgroundContext() // Use background context
        var result: Result<Void, Error> = .success(())
        
        context.performAndWait {
            let feedbackEntity = FeedbackEntity(context: context)
            feedbackEntity.id = feedback.id
            feedbackEntity.city = feedback.city
            feedbackEntity.country = feedback.country
            feedbackEntity.reportedTemperature = feedback.reportedTemperature
            feedbackEntity.reportedCondition = feedback.reportedCondition
            feedbackEntity.actualTemperature = feedback.actualTemperature
            feedbackEntity.actualCondition = feedback.actualCondition
            
            if context.hasChanges {
                do {
                    try context.save()
                    print("Successfully saved feedback to Core Data.")
                } catch {
                    print("Could not save feedback. \(error)")
                    result = .failure(CoreDataError.feedbackSaveError)
                }
            }
        }
        return result
    }
    
    // Fetches all feedbacks from CoreData Entity
    func fetchAllFeedbacks() -> Result<[FeedbackModel], Error> {
        let fetchRequest = NSFetchRequest<FeedbackEntity>(entityName: "FeedbackEntity")
        do {
            let cdFeedbacks = try container.viewContext.fetch(fetchRequest)
            let feedbackModels = cdFeedbacks.map {
                FeedbackModel(
                    id: $0.id!,
                    city: $0.city!,
                    country: $0.country!,
                    reportedTemperature: $0.reportedTemperature,
                    reportedCondition: $0.reportedCondition!,
                    actualTemperature: $0.actualTemperature,
                    actualCondition: $0.actualCondition!
                )
            }
            return .success(feedbackModels)
        } catch {
            print("Failed fetching feedbacks: \(error)")
            return .failure(CoreDataError.feedbackFetchError)
        }
    }
    
    // Deletes a certain feedback from the list
    func deleteFeedback(feedback: FeedbackModel) -> Result<Void, Error> {
        let fetchRequest: NSFetchRequest<FeedbackEntity> = FeedbackEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", feedback.id as CVarArg)
        
        if let result = try? container.viewContext.fetch(fetchRequest),
           let feedbackEntity = result.first {
            container.viewContext.delete(feedbackEntity)
            do {
                try container.viewContext.save()
                return .success(())
            } catch {
                print("Failed to delete feedback: \(error)")
                return .failure(CoreDataError.feedbackSaveAfterDeleteError)
            }
        } else {
            return .failure(CoreDataError.feedbackFetchErrorDuringDeletion)
        }
    }
}


// Additional utility extension to get start and end of the day for a given date.
extension Date {
    // Gets the start of the day for the current date.
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    // Gets the end of the day for the current
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

