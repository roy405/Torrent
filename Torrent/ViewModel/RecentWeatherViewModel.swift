//
//  RecentWeatherViewModel.swift
//  Torrent
//
//  Created by Cube on 9/28/23.
//

import Foundation
import CoreData

// ViewModel for managing RecentWeather-related data and operations.
class RecentWeatherViewModel: ObservableObject {
    // Published property to keep track of recent weather data
    @Published var recentWeatherData: [RecentWeather] = []
    @Published var lastError: CoreDataError?

    
    // Initializer: Sets up the observer to fetch recent weather data when new data is added
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchRecentWeatherFromCoreData),
                                               name: NSNotification.Name("NewDataAdded"),
                                               object: nil)
    }

    // Deinitializer: Removes the observer
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name("NewDataAdded"),
                                                  object: nil)
    }
    
    // Fetches recent weather data from Core Data using PersistenceController
    @objc func fetchRecentWeatherFromCoreData() {
        switch PersistenceController.shared.fetchAllWeatherBySelectCity() {
        case .success(let fetchedResults):
            self.recentWeatherData = fetchedResults.map { RecentWeather(recentWeatherEntity: $0) }
            print(self.recentWeatherData) // For debugging purposes, consider removing for production
        case .failure(let error as CoreDataError):
            self.lastError = error
        case .failure(_):
            self.lastError = CoreDataError.recentWeatherForCityFetchError // or any other appropriate default error
        }
    }
    
    
    // Deletes selected weather data from Core Data and refreshes the data afterward
    func deleteWeather(at offsets: IndexSet) {
        offsets.forEach { index in
            let weather = self.recentWeatherData[index]
            if let id = weather.id {
                switch PersistenceController.shared.deleteWeatherByCity(withID: id) {
                case .success:
                    // Successfully deleted
                    break
                case .failure(let error as CoreDataError):
                    self.lastError = error
                    print("Error deleting weather: \(error.localizedDescription)")
                    // You can also consider showing an error message to the user here
                case .failure(_):
                    self.lastError = CoreDataError.recentWeatherForCityDeleteError
                    print("Error deleting weather: unknown error.")
                    // You can also consider showing a default error message to the user here
                }
            }
        }
        fetchRecentWeatherFromCoreData()  // Refresh the data after deletion
    }
}

