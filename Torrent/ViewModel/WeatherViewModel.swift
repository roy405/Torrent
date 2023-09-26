//
//  WeatherViewModel.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import Foundation
import Combine
import CoreData

class WeatherViewModel: ObservableObject {
    @Published var location: String = ""
    @Published var temperature: Double = 0.0
    @Published var conditionText: String = ""
    @Published var conditionIconURL: URL? = nil
    
    var cancellables: Set<AnyCancellable> = []
    
    func fetchWeatherForCity(_ cityName: String) {
          getWeatherDataFromAPI(city: cityName)
              .sink { completion in
                  switch completion {
                  case .finished: break
                  case .failure(let error):
                      print("Error fetching weather data: \(error)")
                  }
              } receiveValue: { weather in
                  self.location = "\(weather.location.name), \(weather.location.country)"
                  self.temperature = weather.current.temp_c
                  self.conditionText = weather.current.condition.text
                  self.conditionIconURL = URL(string: "https:" + weather.current.condition.icon)
                  
                  // Saving the fetched weather data to Core Data
                  self.saveWeatherToCoreData(
                      city: weather.location.name,
                      country: weather.location.country,
                      temperature: weather.current.temp_c,
                      condition: weather.current.condition.text,
                      iconURL: "https:" + (weather.current.condition.icon )
                  )
                  
              }
              .store(in: &cancellables)
      }
    
    func getWeatherDataFromAPI(city: String) -> AnyPublisher<WeatherResponse, Error> {
        let headers = [
            "X-RapidAPI-Key": "620035982dmshfefc0b106524436p1ef359jsn8f2cb31aa928",
            "X-RapidAPI-Host": "weatherapi-com.p.rapidapi.com"
        ]
        
        let safeCityString = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        guard let url = URL(string: "https://weatherapi-com.p.rapidapi.com/current.json?q=\(safeCityString)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func saveWeatherToCoreData(city: String, country: String, temperature: Double, condition: String, iconURL: String) {
        let context = PersistenceController.shared.container.viewContext
        
        // Check if the city already exists
        let fetchRequest: NSFetchRequest<RecentWeatherEntity> = RecentWeatherEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city == %@ AND country == %@", city, country)
        let existingEntities = try? context.fetch(fetchRequest)
        if let existingEntity = existingEntities?.first {
            // City already exists, update its properties
            existingEntity.temperature = temperature
            existingEntity.iconURL = iconURL
            existingEntity.conditionText = condition
            try? context.save()
            return
        }
        
        let recentWeather = RecentWeatherEntity(context: context)
        recentWeather.id = UUID()
        recentWeather.city = city
        recentWeather.country = country
        recentWeather.temperature = temperature
        recentWeather.iconURL = iconURL
        recentWeather.conditionText = condition
        do {
            try context.save()
            NotificationCenter.default.post(name: NSNotification.Name("NewDataAdded"), object: nil)
        } catch {
            print("Error saving weather to Core Data: \(error)")
        }
    }
}
