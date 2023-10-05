//
//  ImageLoader.swift
//  Torrent
//
//  Created by Cube on 10/01/23.
//

import CoreLocation
import Combine

// `LocationManager` is responsible for managing location-related tasks like fetching the user's location and the corresponding weather.
class LocationManager: NSObject, CLLocationManagerDelegate {
    // Core location's manager for location updates.
    private var locationManager = CLLocationManager()
    // A controller responsible for persistence operations, presumably using CoreData.
    private let persistenceController = PersistenceController.shared
    // ViewModels to manage weather data.
    private let weatherViewModel = WeatherViewModel()
    private let currentWeatherViewModel = CurrentWeatherViewModel()
    // Timer to schedule periodic location updates.
    private var updateTimer: Timer?
    // Published property to notify subscribers of the authorization status changes.
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    // Combine publishers for publisher/subscriber pattern of exception handling and reporting to users
    var failedToGetCityNamePublisher = PassthroughSubject<Void, Never>()
    var locationDeniedErrorPublisher = PassthroughSubject<Void, Never>()
    var locationRestrictedErrorPublisher = PassthroughSubject<Void, Never>()
    
    // Flag to avoid fetching location multiple times.
    private var didFetchLocation: Bool = false
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // Requests the necessary authorization to access the user's location.
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization() // or requestAlwaysAuthorization() based on your needs
    }
    
    // Delegate method called when the authorization status changes.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        self.authorizationStatus = status
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            scheduleLocationUpdate()
        case .denied:
            locationDeniedErrorPublisher.send(())
        case .restricted:
            locationRestrictedErrorPublisher.send(())
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
        
    // Schedule periodic location updates.
    private func scheduleLocationUpdate() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3 * 60 * 60, repeats: true) { [weak self] _ in
            self?.fetchAndUpdateLocation()
        }
        fetchAndUpdateLocation()
    }
    
    // Initiates location updates.
    private func fetchAndUpdateLocation() {
        didFetchLocation = false
        locationManager.startUpdatingLocation()
    }
    
    // Requests for authorization if not determined.
    func checkAndRequestAuthorization() {
        requestAuthorization()
    }
    
    // Delegate method called when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !didFetchLocation else {
            // Locatoin already fetched, so returning
            return
        }
        
        if let location = locations.last {
            didFetchLocation = true
            processLocationData(for: location)
            locationManager.stopUpdatingLocation()
        }
    }
    
    // Processes the obtained location data.
    private func processLocationData(for location: CLLocation) {
        reverseGeocode(location: location) { cityName in
            if let cityName = cityName {
                
                // Fetching the current weather data for the view update
                self.fetchCurrentWeatherData(for: cityName) {
                    // At this point, the currentWeatherViewModel properties have been updated
                    // and it will be reflected in the CurrentWeatherView.
                }
                
                // Fetching weather data using the city name
                self.fetchWeatherData(for: cityName) {
                    
                    // Check for a saved recommendation for the current day
                    switch self.persistenceController.fetchRecommendationsForToday() {
                    
                    case .success(let currentDayRecommendations):
                        if currentDayRecommendations.isEmpty {
                            // No recommendation saved for today.
                            // Generate a new recommendation using the fetched weather data
                            let recommendation = self.generateRecommendation(temperature: self.weatherViewModel.temperature, conditionText: self.weatherViewModel.conditionText)
                            
                            // Save the new recommendation to persistence
                            let recommendationToSave = Recommendation(
                                id: UUID(),
                                dateAndTime: Date(),
                                recommendation: recommendation,
                                weatherCondition: self.weatherViewModel.conditionText
                            )
                            switch self.persistenceController.saveRecommendationToCoreData(recommendation: recommendationToSave) {
                            case .success():
                                print("Successfully saved recommendation to Core Data.")
                            case .failure(let saveError):
                                print("Failed to save recommendation. Error: \(saveError)")
                            }
                        } else {
                            // Recommendation already saved for today
                            if let todaysRecommendation = currentDayRecommendations.first {
                                print(todaysRecommendation)
                            }
                        }
                        
                    case .failure(_):
                        print("Failed to fetch recommendations for today.")
                    }
                }
            } else {
                print("Failed to obtain city name from coordinates.")
                self.failedToGetCityNamePublisher.send(())
            }
        }
    }


    // Converts the given location into human-readable address details.
    private func reverseGeocode(location: CLLocation, completion: @escaping (String?) -> Void) {
        print(location)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Failed to get city name: \(error)")
                self.failedToGetCityNamePublisher.send(())
                completion(nil)
            } else {
                let cityName = placemarks?.first?.locality
                completion(cityName)
            }
        }
    }
    
    // Fetches weather data for a given city.
    private func fetchWeatherData(for city: String, completion: @escaping () -> Void) {
        // Using the ViewModel's method to fetch weather
        weatherViewModel.fetchWeatherForRecommendation(city) {
            completion() // This is executed once the weatherViewModel updates its properties with the fetched weather data
        }
    }
    
    // Fetches current weather data for a given city.
    private func fetchCurrentWeatherData(for city: String, completion: @escaping() -> Void){
        currentWeatherViewModel.fetchCurrentWeatherData(for: city){
            completion()
        }
    }
    
    // Generates a recommendation based on the weather details.
    private func generateRecommendation(temperature: Double, conditionText: String) -> String {
        let baseWeatherText = "Today's weather: \(conditionText). "
        if temperature > 35 {
            return baseWeatherText + "It's scorching hot! Be careful of bushfires and stay hydrated."
        } else if temperature < 0 {
            return baseWeatherText + "It's freezing outside! Bundle up and be cautious of icy conditions."
        } else if conditionText.lowercased().contains("rain") {
            return baseWeatherText + "Bring an umbrella. Going hiking might be a problem today."
        } else if conditionText.lowercased().contains("sunny") {
            return baseWeatherText + "It's a sunny day! Make sure to fill up your water bottle."
        } else if conditionText.lowercased().contains("snow") {
            return baseWeatherText + "It's snowing! Make sure to wear warm clothes and tread carefully."
        } else if conditionText.lowercased().contains("thunderstorm") {
            return baseWeatherText + "There's a thunderstorm. Stay indoors and avoid using electrical appliances."
        } else if conditionText.lowercased().contains("fog") {
            return baseWeatherText + "Visibility might be low due to fog. Drive carefully."
        } else if conditionText.lowercased().contains("overcast") {
            return baseWeatherText + "The sky is overcast. A good day for indoor activities."
        } else if conditionText.lowercased().contains("windy") {
            return baseWeatherText + "It's quite windy outside. Hold onto your hat!"
        } else if conditionText.lowercased().contains("partly cloudy"){
            return baseWeatherText + "It's partly cloudy. You might want to carry a light jacket."
        }
        return baseWeatherText + "Enjoy your day!"
    }
    
    // Cancels the timer when the instance is deallocated.
    deinit {
        updateTimer?.invalidate()
    }
}

