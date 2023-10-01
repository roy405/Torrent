//
//  ImageLoader.swift
//  Torrent
//
//  Created by Cube on 10/01/23.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var weatherViewModel = WeatherViewModel()
    private var recommendationViewModel = RecommendationViewModel()
    
    @Published var latestRecommendation: String = ""
    
    // UserDefaults property for storing last fetch date
    private var lastFetchDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "lastFetchDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastFetchDate")
        }
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        if shouldFetchWeather() {
            locationManager.startUpdatingLocation()
        } else {
            print("Already fetched weather data within the last 24 hours. Skipping for now.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location manager did update locations.")
        guard let latestLocation = locations.last else { return }

        fetchCityName(from: latestLocation.coordinate) { cityName in
            print("Fetched city name: \(cityName)")
            
            self.weatherViewModel.fetchWeatherForRecommendation(cityName) {
                // Once fetching the weather data completes:
                
                // Generate and save recommendation based on fetched weather data
                self.latestRecommendation = self.generateRecommendation(from: self.weatherViewModel)

                // Save the recommendation to Core Data
                self.recommendationViewModel.saveRecommendation(
                    id: UUID(),
                    dateAndTime: Date(),
                    recommendation: self.latestRecommendation,
                    weatherCondition: self.weatherViewModel.conditionText
                )
                
                self.lastFetchDate = Date()
                // Stop updating location after fetching weather data.
                self.locationManager.stopUpdatingLocation()
            }
        }
    }


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location authorization granted. Starting location updates...")
            startUpdatingLocation()
        case .denied, .restricted:
            print("Location authorization denied or restricted.")
        case .notDetermined:
            print("Location authorization not determined yet.")
        default:
            print("Unknown location authorization status.")
        }
    }

    
    func fetchCityName(from coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding location: \(error)")
                return
            }
            
            if let firstPlacemark = placemarks?.first, let city = firstPlacemark.locality {
                completion(city)
            }
        }
    }
    
    func generateRecommendation(from viewModel: WeatherViewModel) -> String {
        let baseWeatherText = "Weather: \(viewModel.conditionText) "
        print("HELLO THERE this is the baseWeatherText \(baseWeatherText)")
        print("look here \(viewModel.location) \(viewModel.temperature) \(viewModel.latitude) \(viewModel.longitude)")
        // Using temperature and condition text to generate recommendations
        if viewModel.temperature > 35 {
            return baseWeatherText + "It's scorching hot! Be careful of bushfires and stay hydrated."
        } else if viewModel.temperature < 0 {
            return baseWeatherText + "It's freezing outside! Bundle up and be cautious of icy conditions."
        } else if viewModel.conditionText.lowercased().contains("rain") {
            return baseWeatherText + "Bring an umbrella. Going hiking might be a problem today."
        } else if viewModel.conditionText.lowercased().contains("sunny") {
            return baseWeatherText + "It's a sunny day! Make sure to fill up your water bottle."
        } else if viewModel.conditionText.lowercased().contains("snow") {
            return baseWeatherText + "It's snowing! Make sure to wear warm clothes and tread carefully."
        } else if viewModel.conditionText.lowercased().contains("thunderstorm") {
            return baseWeatherText + "There's a thunderstorm. Stay indoors and avoid using electrical appliances."
        } else if viewModel.conditionText.lowercased().contains("fog") {
            return baseWeatherText + "Visibility might be low due to fog. Drive carefully."
        } else if viewModel.conditionText.lowercased().contains("overcast") {
            return baseWeatherText + "The sky is overcast. A good day for indoor activities."
        } else if viewModel.conditionText.lowercased().contains("windy") {
            return baseWeatherText + "It's quite windy outside. Hold onto your hat!"
        } else if viewModel.conditionText.lowercased().contains("partly cloudy"){
            return baseWeatherText + "It's partly cloudy. You might want to carry a light jacket."
        }
        return baseWeatherText + "Enjoy your day!"
    }
    
    // Helper method to determine if a weather data fetch should be performed
    private func shouldFetchWeather() -> Bool {
        guard let lastDate = lastFetchDate else {
            // If there's no stored date, this is the first request.
            return timeCheck()
        }
        
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(lastDate)
        let fetchCondition = timeCheck() && timeInterval >= 86400 // 86400 seconds is 24 hours
        print("Should fetch weather? \(fetchCondition) | Last fetch time interval: \(timeInterval)")
        return fetchCondition
    }
    
    private func timeCheck() -> Bool {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        let currentMinute = calendar.component(.minute, from: Date())
        
        print("Checking time. Current hour: \(currentHour), Current minute: \(currentMinute)")
        
        return currentHour == 8 && currentMinute <= 5
    }
}
