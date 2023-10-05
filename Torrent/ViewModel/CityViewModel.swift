//
//  CityViewModel.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import Foundation
import Combine
import CoreData
import UIKit

// This view model manages and provides city data to the associated views.
class CityViewModel: ObservableObject {
    
    // Published properties to notify views of updates
    @Published var cities: [CityData] = []
    @Published var error: Error?
    
    // Structure to map raw data from JSON file
    private struct RawCityData: Codable {
        var id: Int32
        var cityname: String
        var country: String
        var latitude: String
        var longitude: String
    }
    
    // Initializes the CityViewModel by attempting to fetch existing cities
    init() {
        fetchCities()
    }
    
    // Fetches cities either from Core Data or JSON (if Core Data is empty)
    func fetchCities() {
        // Attempt to fetch cities from Core Data
        switch PersistenceController.shared.fetchCities() {
        case .success(let fetchedCities):
            // If there are no cities in Core Data, load them from the JSON file
            if fetchedCities.isEmpty {
                loadCitiesFromJSON()
            } else {
                self.cities = fetchedCities
            }
        case .failure(let error):
            // If there's an error fetching cities, set the error property
            self.error = error
        }
    }
    
    // Loads cities from the bundled JSON file and saves them to Core Data
    func loadCitiesFromJSON() {
        // Check for the existence of the 'cities.json' file in the app bundle
        if let url = Bundle.main.url(forResource: "cities", withExtension: "json") {
            do {
                // Load and decode the JSON data
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                
                let rawCities = try decoder.decode([RawCityData].self, from: data)
                
                // Convert raw data into the app's CityData structure
                let cities: [CityData] = rawCities.map { rawCity in
                    return CityData(
                        id: rawCity.id,
                        cityname: rawCity.cityname,
                        country: rawCity.country,
                        latitude: Double(rawCity.latitude) ?? nil,
                        longitude: Double(rawCity.longitude) ?? nil
                    )
                }
                
                // Save the converted cities to Core Data
                switch PersistenceController.shared.saveCitiesToCoreData(cities) {
                case .success():
                    // If saving is successful, fetch the cities again to update the UI
                    fetchCities()
                case .failure(let error):
                    // If there's an error saving cities, set the error property
                    self.error = error
                }
            } catch {
                // Handle any errors during JSON decoding or file reading
                self.error = error
            }
        }
    }
}


