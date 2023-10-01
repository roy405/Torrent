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
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    var cancellables: Set<AnyCancellable> = []
    
    func fetchWeatherForRecommendation(_ cityName: String, completion: @escaping () -> Void) {
        getWeatherDataFromAPI(city: cityName)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Completed successfully.")
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            } receiveValue: { weather in
                print("Received weather data: \(weather)")
                    
                self.location = "\(weather.location.name), \(weather.location.country)"
                self.temperature = weather.current.temp_c
                self.conditionText = weather.current.condition.text
                self.conditionIconURL = URL(string: "https:" + weather.current.condition.icon)
                    
                // Fetch latitude and longitude from API response
                self.latitude = weather.location.lat
                self.longitude = weather.location.lon
                completion()
            }
            .store(in: &cancellables)
    }
    
    func fetchWeatherByCityForMap(_ cityName: String){
        getWeatherDataFromAPI(city: cityName)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Completed successfully.")
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            } receiveValue: { weather in
                print("Received weather data: \(weather)")
                
                self.location = "\(weather.location.name), \(weather.location.country)"
                self.temperature = weather.current.temp_c
                self.conditionText = weather.current.condition.text
                self.conditionIconURL = URL(string: "https:" + weather.current.condition.icon)
                
                // Fetch latitude and longitude from API response
                self.latitude = weather.location.lat
                self.longitude = weather.location.lon
            }
            .store(in: &cancellables)
    }
        
    func fetchWeatherForCity(_ cityName: String) {
        getWeatherDataFromAPI(city: cityName)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Completed successfully.")
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            } receiveValue: { weather in
                print("Received weather data: \(weather)")
                
                self.location = "\(weather.location.name), \(weather.location.country)"
                self.temperature = weather.current.temp_c
                self.conditionText = weather.current.condition.text
                self.conditionIconURL = URL(string: "https:" + weather.current.condition.icon)
                print(self.location, self.temperature, self.conditionText, self.conditionIconURL!)
                
                // Fetch latitude and longitude from API response
                self.latitude = weather.location.lat
                self.longitude = weather.location.lon
                print("Is here in fetchweatherforcity" + weather.location.name + weather.location.country)
                
                // Modify the save method to include latitude and longitude
                self.saveWeatherToCoreData(
                    city: weather.location.name,
                    country: weather.location.country,
                    temperature: weather.current.temp_c,
                    condition: weather.current.condition.text,
                    iconURL: "https:" + (weather.current.condition.icon),
                    latitude: self.latitude,
                    longitude: self.longitude
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
            print("Failed to create URL.")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        print("Making request to: \(url)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap { data -> WeatherResponse in
                let decodedResponse = try JSONDecoder().decode(DecodableWeatherResponse.self, from: data)
                return WeatherResponse(id: UUID(), location: decodedResponse.location, current: decodedResponse.current)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    
    // Update the saveWeatherToCoreData function signature to include latitude and longitude
    func saveWeatherToCoreData(city: String, country: String, temperature: Double, condition: String, iconURL: String, latitude: Double, longitude: Double) {
        let context = PersistenceController.shared.container.viewContext
        
        // Check if the city already exists
        let fetchRequest: NSFetchRequest<RecentWeatherEntity> = RecentWeatherEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city == %@ AND country == %@", city, country)
        do {
            let existingEntities = try context.fetch(fetchRequest)
            
            if let existingEntity = existingEntities.first {
                // City already exists, update its properties
                existingEntity.temperature = temperature
                existingEntity.iconURL = iconURL
                existingEntity.conditionText = condition
                existingEntity.latitude = latitude   // Update latitude
                existingEntity.longitude = longitude // Update longitude
                try context.save()
                return
            }
            let recentWeather = RecentWeatherEntity(context: context)
            recentWeather.id = UUID()
            recentWeather.city = city
            recentWeather.country = country
            recentWeather.temperature = temperature
            recentWeather.iconURL = iconURL
            recentWeather.conditionText = condition
            recentWeather.latitude = latitude   // Set latitude
            recentWeather.longitude = longitude // Set longitude
            try context.save()
            NotificationCenter.default.post(name: NSNotification.Name("NewDataAdded"), object: nil)
        } catch {
            print("Error saving or fetching weather from Core Data: \(error)")
        }
    }
}
