//
//  ImageLoader.swift
//  Torrent
//
//  Created by Cube on 10/01/23.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    private let persistenceController = PersistenceController.shared
    private let weatherViewModel = WeatherViewModel()
    private let currentWeatherViewModel = CurrentWeatherViewModel()
    private var updateTimer: Timer?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    // Use this to stop location updates once we have accurate enough data
    private var didFetchLocation: Bool = false
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization() // or requestAlwaysAuthorization() based on your needs
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        self.authorizationStatus = status
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Now that we have permission, we can start fetching the location
            scheduleLocationUpdate()
        default:
            // Handle other cases or inform the user they need to grant location access
            break
        }
    }
    
    
    private func scheduleLocationUpdate() {
        // Invalidate any existing timer
        updateTimer?.invalidate()
        
        // Schedule a new timer to run every 3 hours
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3 * 60 * 60, repeats: true) { [weak self] _ in
            self?.fetchAndUpdateLocation()
        }
        
        // Trigger the first location update immediately
        fetchAndUpdateLocation()
    }
    
    private func fetchAndUpdateLocation() {
        didFetchLocation = false
        locationManager.startUpdatingLocation()
    }
    
    func checkAndRequestAuthorization() {
        requestAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !didFetchLocation else {
            // We have already fetched the location
            return
        }
        
        if let location = locations.last {
            didFetchLocation = true
            processLocationData(for: location)
            locationManager.stopUpdatingLocation()
        }
    }
    
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
                    let currentDayRecommendations = self.persistenceController.fetchRecommendationsForToday()
                    
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
                        self.persistenceController.saveRecommendationToCoreData(recommendation: recommendationToSave)
                        
                    } else {
                        // Recommendation already saved for today
                        if let todaysRecommendation = currentDayRecommendations.first {
                            print(todaysRecommendation)
                        }
                    }
                }
            } else {
                print("Failed to obtain city name from coordinates.")
                // Handle the scenario where a city name wasn't obtained.
                // You might want to provide a default behavior or notify the user.
            }
        }
    }

    private func updateDashboardWeather(weather: WeatherViewModel) {
        // Your logic to update the weather on the dashboard.
        // For this example, I'll just print the weather's condition text
        print("Dashboard Weather Update: \(weather.conditionText)")
    }

    
    private func reverseGeocode(location: CLLocation, completion: @escaping (String?) -> Void) {
        print(location)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                print("Locality: \(placemark.locality ?? "None")")
                print("Administrative Area: \(placemark.administrativeArea ?? "None")")
                print("Sub Locality: \(placemark.subLocality ?? "None")")
                print("Name: \(placemark.name ?? "None")")
            }
            if let error = error {
                print("Failed to get city name: \(error)")
                completion(nil)
            } else {
                let cityName = placemarks?.first?.locality
                print(cityName ?? "Did not get city name")
                completion(cityName)
            }
        }
    }
    
    
    private func fetchWeatherData(for city: String, completion: @escaping () -> Void) {
        // Using the ViewModel's method to fetch weather
        print("1 . fetchWeatherDeata is running")
        weatherViewModel.fetchWeatherForRecommendation(city) {
            
            completion() // This is executed once the weatherViewModel updates its properties with the fetched weather data
        }
    }
    
    private func fetchCurrentWeatherData(for city: String, completion: @escaping() -> Void){
        print("2 . fetchCurrentWeatherData is running")
        currentWeatherViewModel.fetchCurrentWeatherData(for: city){
            completion()
        }
    }
    
    private func generateRecommendation(temperature: Double, conditionText: String) -> String {
        let baseWeatherText = "Today's weather: \(conditionText). "
        print("getting reccomm!")
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
    
    deinit {
        updateTimer?.invalidate()
    }
}

