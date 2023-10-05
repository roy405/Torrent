//
//  TorrentApp.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI

@main
struct TorrentApp: App {
    let persistenceController = PersistenceController.shared
    var locationManager = LocationManager()  // Changed this to @ObservedObject to observe changes.
    @State private var appState: AppState = .waitingForPermission
    @State private var showCityNameError = false
    @State private var showLocationDeniedError = false
    @State private var showLocationRestrictedError = false

    var body: some Scene {
        WindowGroup {
            Group {
                switch appState {
                case .waitingForPermission:
                    Text("Waiting for location permission...")
                case .permissionDenied:
                    Text("Permission denied. Please enable location services in settings.")
                case .ready:
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
            .alert(isPresented: $showCityNameError) {
                Alert(title: Text("Error"),
                      message: Text("Failed to obtain city name from coordinates. Please try again."),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showLocationDeniedError) {
                Alert(title: Text("Location Access Denied"),
                      message: Text("Hi, This is a Weather app and for location accuracy, it is very imminent for the location services to be active. Don't worry, we don't do background tasks or access your weather in the background, only when you use the app and briefly. Thank you for your consideration."),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showLocationRestrictedError) {
                Alert(title: Text("Location Restricted"),
                      message: Text("Parental Restrictions are preventing you from using the App. We are deeply sorry :("),
                      dismissButton: .default(Text("OK")))
            }
            .onAppear {
                // Use the locationManager to initiate the check
                self.locationManager.checkAndRequestAuthorization()
            }
            .onReceive(locationManager.$authorizationStatus) { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.appState = .ready
                case .denied, .restricted:
                    self.appState = .permissionDenied
                default:
                    break
                }
            }
            .onReceive(locationManager.failedToGetCityNamePublisher) { _ in
                self.showCityNameError = true
            }
            .onReceive(locationManager.locationDeniedErrorPublisher) { _ in
                self.showLocationDeniedError = true
            }
            .onReceive(locationManager.locationRestrictedErrorPublisher) { _ in
                self.showLocationRestrictedError = true
            }
        }
    }
}



