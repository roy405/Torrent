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
    var locationManager = LocationManager()  // Instantiate the LocationManager here
    @State private var appState: AppState = .waitingForPermission

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
        }
    }
}


