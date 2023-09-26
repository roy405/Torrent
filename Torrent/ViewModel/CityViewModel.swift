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

class CityViewModel: ObservableObject {
    
    @Published var cities: [CityData] = []
    
    private struct RawCityData: Codable {
        var id: Int32
        var cityname: String
        var country: String
        var latitude: String
        var longitude: String
    }

    private var context: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchCitiesFromCoreData()
    }
    
    func fetchCitiesFromCoreData() {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        
        if let fetchedCities = try? context.fetch(request), !fetchedCities.isEmpty {
            self.cities = fetchedCities.map { CityData(id: $0.id,
                                                       cityname: $0.cityname ?? "",
                                                       country: $0.country ?? "",
                                                       latitude: $0.latitude,
                                                       longitude: $0.longitude) }
        } else {
            loadCitiesFromJSON()
        }
    }
    
    func loadCitiesFromJSON() {
        if let url = Bundle.main.url(forResource: "cities", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                
                let rawCities = try decoder.decode([RawCityData].self, from: data)
                
                let cities: [CityData] = rawCities.map { rawCity in
                    return CityData(
                        id: rawCity.id,
                        cityname: rawCity.cityname,
                        country: rawCity.country,
                        latitude: Double(rawCity.latitude) ?? nil,
                        longitude: Double(rawCity.longitude) ?? nil
                    )
                }

                saveToCoreData(cities)
                fetchCitiesFromCoreData()
            } catch {
                print("Error reading JSON: \(error)")
            }
        }
    }

    
    private func saveToCoreData(_ cities: [CityData]) {
        for city in cities {
            let cityEntity = NSEntityDescription.insertNewObject(forEntityName: "CityEntity", into: context) as! CityEntity
            cityEntity.id = city.id
            cityEntity.cityname = city.cityname
            cityEntity.country = city.country
            cityEntity.latitude = city.latitude ?? 0.0
            cityEntity.longitude = city.longitude ?? 0.0
        }
        do {
            try context.save()
        } catch {
            print("Failed saving: \(error)")
        }
    }
}
