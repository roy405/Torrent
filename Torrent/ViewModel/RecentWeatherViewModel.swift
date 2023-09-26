//
//  RecentWeatherViewModel.swift
//  Torrent
//
//  Created by Cube on 9/28/23.
//

import Foundation
import CoreData

class RecentWeatherViewModel: ObservableObject {
    @Published var recentWeatherData: [RecentWeather] = []
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchRecentWeatherFromCoreData), name: NSNotification.Name("NewDataAdded"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NewDataAdded"), object: nil)
    }
    
    @objc func fetchRecentWeatherFromCoreData() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<RecentWeatherEntity> = RecentWeatherEntity.fetchRequest()
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            // Convert fetched WeatherEntity objects to RecentWeather structs
            self.recentWeatherData = fetchedResults.map { RecentWeather(recentWeatherEntity: $0) }
        } catch {
            print("Error fetching recent weather from Core Data: \(error)")
        }
    }
    
    func deleteWeather(at offsets: IndexSet) {
        let context = PersistenceController.shared.container.viewContext
        
        offsets.forEach { index in
            let weather = self.recentWeatherData[index]
            
            // Fetch the managed object to be deleted
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecentWeatherEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", weather.id! as CVarArg)
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Error deleting weather: \(error)")
            }
        }
        
        fetchRecentWeatherFromCoreData()  // Refresh the data after deletion
    }
}
