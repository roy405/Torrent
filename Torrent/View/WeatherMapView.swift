//
//  WeatherMapView.swift
//  Torrent
//
//  Created by Cube on 9/30/23.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct WeatherMapView: View {
    // MARK: - PROPERTIES
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), // Coordinates for Sydney
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var cityName = ""
    @State private var lastUpdate = Date()
    @State private var cancellable: AnyCancellable?
    @State private var lastFetchedCoordinate: CLLocationCoordinate2D?
    @ObservedObject var weatherViewModel = WeatherViewModel()
    @Binding var isShowingMap: Bool

    var body: some View {
        ZStack {
            NavigationView {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [AnnotatedItem(coordinate: region.center)]) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        VStack(alignment: .center) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                            
                            // Weather Data Display
                            if !weatherViewModel.conditionText.isEmpty {
                                VStack(spacing: 2) {
                                    Text("\(weatherViewModel.temperature, specifier: "%.1f")°C")
                                        .font(.footnote)
                                    Text(weatherViewModel.conditionText)
                                        .font(.caption)
                                        .lineLimit(1)
                                    if let iconURL = weatherViewModel.conditionIconURL {
                                        AsyncImage(url: iconURL) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image.resizable().scaledToFill()
                                            case .failure:
                                                Image(systemName: "xmark.circle")
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(width: 30, height: 30)
                                    }
                                }
                                .padding(5)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(radius: 2)
                            }
                        }
                    }
                }
                .onReceive(Just(region)) { newRegion in
                    lastUpdate = Date()
                    
                    cancellable?.cancel()
                    cancellable = Just(())
                        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
                        .sink { _ in
                            if Date().timeIntervalSince(lastUpdate) >= 3 {
                                // Check if coordinate has changed significantly to warrant a new fetch
                                if shouldFetchDataFor(newCoordinate: newRegion.center) {
                                    fetchCityName(from: newRegion.center)
                                }
                            }
                        }
                }
                .navigationTitle(cityName)
            }
            
            // Close button outside of NavigationView
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isShowingMap.toggle()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                            .padding([.top, .trailing], 16)
                    }
                }
                Spacer()
            }
        }
    }

    func fetchCityName(from coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding location: \(error)")
                return
            }
            
            if let firstPlacemark = placemarks?.first,
               let city = firstPlacemark.locality {
                cityName = city
                print(cityName)
                weatherViewModel.fetchWeatherByCityForMap(city)
            }
        }
    }
    
    func shouldFetchDataFor(newCoordinate: CLLocationCoordinate2D) -> Bool {
        // Define a threshold for significant location changes
        let threshold: CLLocationDegrees = 0.01 // This is just a small value; you can adjust based on your needs

        // If we haven't fetched before, then proceed
        guard let lastCoordinate = lastFetchedCoordinate else {
            lastFetchedCoordinate = newCoordinate
            return true
        }

        let deltaLatitude = abs(newCoordinate.latitude - lastCoordinate.latitude)
        let deltaLongitude = abs(newCoordinate.longitude - lastCoordinate.longitude)

        // If the change in location is significant, update the last fetched coordinate and return true
        if deltaLatitude > threshold || deltaLongitude > threshold {
            lastFetchedCoordinate = newCoordinate
            return true
        }

        return false
    }
}

struct AnnotatedItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

