//
//  ForecastViewModel.swift
//  Torrent
//
//  Created by Cube on 10/13/23.
//

import Foundation
import Combine
import CoreData

class ForecastViewModel: ObservableObject{
    @Published var forecastLocation: ForecastLocation?
    @Published var forecasts: [Forecast] = []
    
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
        
    // Function to fetch forecast data and save it to Core Data using
    // the save function to update exisitng or create new forecast data by location
    func getWeatherForecastData(city: String) -> AnyPublisher<Void, Error> {

        let headers = [
            "X-RapidAPI-Key": Constants.RAPIDAPIKEY,
            "X-RapidAPI-Host": Constants.RAPIDAPIHOST
        ]
        
        let safeCityString = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        
        guard let url = URL(string: "https://weatherapi-com.p.rapidapi.com/forecast.json?q=\(safeCityString)&days=3") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ForecastAPIModel.self, decoder: JSONDecoder())
            .flatMap { apiData -> AnyPublisher<Void, Error> in
                let locationModel = ForecastLocation(name: apiData.location.name,
                                                     region: apiData.location.region,
                                                     country: apiData.location.country,
                                                     lat: apiData.location.lat,
                                                     lon: apiData.location.lon)
                let forecasts: [Forecast] = apiData.forecast.forecastday.compactMap{ dayForecast -> Forecast? in
                    guard let date = self.dateFormatter.date(from: dayForecast.date) else {
                        print("Invalid date format in the API response for \(dayForecast.date)")
                        return nil
                    }
                    return Forecast(date: date,
                                    maxtemp_c: dayForecast.day.maxtemp_c,
                                    mintemp_c: dayForecast.day.mintemp_c,
                                    conditionText: dayForecast.day.condition.text)
                }
                // Update the properties
                self.forecastLocation = locationModel
                self.forecasts = forecasts
                
                // Save the data to CoreData
                switch self.persistenceController.saveForecastData(location: locationModel, forecasts: forecasts) {
                case .success():
                    print("Successfully saved forecast data to Core Data.")
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                case .failure(let saveError):
                    print("Failed to save forecast data. Error: \(saveError)")
                    return Fail(error: saveError).eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Function to fetch Latest Forecast data for current location
    func fetchLatestForecastFromCoreData() {
        switch persistenceController.fetchForecasts() {
        case .success(let (location, forecasts)):
            self.forecastLocation = location
            self.forecasts = forecasts
        case .failure(let error):
            print("Failed to fetch forecast data from Core Data: \(error)")
        }
    }


    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust this to match the date format returned by the API
        return formatter
    }()
    
 

}

extension ForecastLocation: CustomStringConvertible {
    var description: String {
        return "ForecastLocation(name: \(name), region: \(region), country: \(country), lat: \(lat), lon: \(lon))"
    }
}


extension Forecast: CustomStringConvertible {
    var description: String {
        return "Forecast(date: \(date), maxtemp_c: \(maxtemp_c), mintemp_c: \(mintemp_c), conditionText: \(conditionText))"
    }
}
