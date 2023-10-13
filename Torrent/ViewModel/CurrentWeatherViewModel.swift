//
//  CurrentWeatherViewModel.swift
//  Torrent
//
//  Created by Cube on 10/2/23.
//

import Foundation
import Combine

// ViewModel responsible for managing CurrentWeather-related data and operations.
class CurrentWeatherViewModel: ObservableObject {
    
    // Published properties for the UI to bind to.
    @Published var temperature: Double = 0.0
    @Published var conditionText: String = ""
    @Published var location: String = ""
    @Published var conditionIconURL: URL?
    @Published var fetchedFromCoreData: Bool = false
    
    // Property to store any errors that may occur during operations.
    @Published var error: Error?
    
    // A cancellable object that represents a type-erased cancellable instance.
    private var cancellable: AnyCancellable?
    
    // Fetches current weather data for a given city from the API.
    func fetchCurrentWeatherData(for city: String, completion: @escaping () -> Void) {
        cancellable = getCurrentWeatherDataFromAPI(city: city)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                    self.error = error  // Store the occurred error
                }
            }, receiveValue: { response in
                self.updateUI(
                    temperature: response.current.temp_c,
                    conditionText: response.current.condition.text,
                    location: "\(response.location.name), \(response.location.country)",
                    iconURL: URL(string: response.current.condition.icon)
                )
                self.saveOrUpdateWeatherInCoreData()
                completion()
            })
    }

    // Updates the UI elements with the provided weather data.
    private func updateUI(temperature: Double, conditionText: String, location: String, iconURL: URL?) {
        self.temperature = temperature
        self.conditionText = conditionText
        self.location = location
        self.conditionIconURL = iconURL
    }
    
    // Makes an API request to fetch current weather data for a provided city.
    private func getCurrentWeatherDataFromAPI(city: String) -> AnyPublisher<WeatherResponse, Error> {
        // Headers required for the API request.
        let headers = [
            "X-RapidAPI-Key": Constants.RAPIDAPIKEY,
            "X-RapidAPI-Host": Constants.RAPIDAPIHOST
        ]
        // Encoding the city name to be URL-safe.
        let safeCityString = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        // Construct the API endpoint URL.
        guard let url = URL(string: "https://weatherapi-com.p.rapidapi.com/current.json?q=\(safeCityString)") else {
            print("Failed to create URL.")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        // Prepare API Request.
        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        // Perform Request
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            // Decode the received data into a `WeatherResponse` object.
            .tryMap { data -> WeatherResponse in
                let decodedResponse = try JSONDecoder().decode(DecodableWeatherResponse.self, from: data)
                return WeatherResponse(id: UUID(), location: decodedResponse.location, current: decodedResponse.current)
            }
            // Ensure the result is delivered on the main thread.
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Saving Or Updating Current Weather (Current weather of current location) by calling CoreData Persistence method
    func saveOrUpdateWeatherInCoreData() {
        let model = CurrentWeatherModel(
            temperature: self.temperature,
            conditionText: self.conditionText,
            conditionIconURL: self.conditionIconURL?.absoluteString ?? "",
            location: self.location
        )

        switch PersistenceController.shared.saveOrUpdateCurrentWeather(from: model) {
        case .success():
            print("Successfully saved/updated current weather in Core Data.")
        case .failure(let error):
            print("Error saving/updating current weather in Core Data: \(error)")
            self.error = error
        }
    }

    // Fetching Current Weather (Current weather of current location) by calling CoreData Persistence method
    func fetchWeatherFromCoreData() {
        switch PersistenceController.shared.fetchCurrentWeather() {
        case .success(let model?):
            self.temperature = model.temperature
            self.conditionText = model.conditionText ?? ""
            self.conditionIconURL = URL(string: model.conditionIconURL ?? "")
            self.location = model.location ?? ""
            self.fetchedFromCoreData = true
        case .success(.none):
            print("No current weather data found in Core Data.")
        case .failure(let error):
            print("Error fetching current weather from Core Data: \(error)")
            self.error = error
        }
    }
}
