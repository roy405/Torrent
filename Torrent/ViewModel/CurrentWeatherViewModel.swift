//
//  CurrentWeatherViewModel.swift
//  Torrent
//
//  Created by Cube on 10/2/23.
//

import Foundation
import Combine


class CurrentWeatherViewModel: ObservableObject {
    
    @Published var temperature: Double = 0.0 
    @Published var conditionText: String = ""
    @Published var location: String = ""
    @Published var conditionIconURL: URL?
    @Published var fetchedFromCoreData: Bool = false
    private var cancellable: AnyCancellable?
    
    

    func fetchCurrentWeatherData(for city: String, completion: @escaping () -> Void) {
        cancellable = getCurrentWeatherDataFromAPI(city: city)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                }
            }, receiveValue: { response in
                // Updated: Using the new function to update UI
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

    
    private func updateUI(temperature: Double, conditionText: String, location: String, iconURL: URL?) {
        self.temperature = temperature
        self.conditionText = conditionText
        self.location = location
        self.conditionIconURL = iconURL
    }

    private func getCurrentWeatherDataFromAPI(city: String) -> AnyPublisher<WeatherResponse, Error> {
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
    
    func saveOrUpdateWeatherInCoreData() {
        let model = CurrentWeatherModel(
            temperature: self.temperature,
            conditionText: self.conditionText,
            conditionIconURL: self.conditionIconURL?.absoluteString ?? "",
            location: self.location
        )
        
        PersistenceController.shared.saveOrUpdateCurrentWeather(from: model)
    }

    func fetchWeatherFromCoreData() {
        if let model = PersistenceController.shared.fetchCurrentWeather() {
            self.temperature = model.temperature
            self.conditionText = model.conditionText ?? ""
            self.conditionIconURL = URL(string: model.conditionIconURL ?? "")
            self.location = model.location ?? ""
            self.fetchedFromCoreData = true
        }
    }
}
