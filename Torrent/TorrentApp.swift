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
    var locationManager = LocationManager()
    @State private var appState: AppState = .waitingForPermission
    
    enum AlertType {
        case locationDenied
        case locationRestricted
        case none
    }
    @State private var currentAlert: AlertType = .none

    var body: some Scene {
        WindowGroup {
            Group {
                switch appState {
                case .waitingForPermission:
                    Text("Waiting for location permission...")
                case .permissionDenied:
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                case .ready:
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { self.currentAlert != .none },
                set: { if !$0 { self.currentAlert = .none } }
            )) {
                switch currentAlert {
                case .locationDenied:
                    return Alert(title: Text("Location Access Denied"),
                                 message: Text("Please enable location services in settings to take full advantage of the app Settings > Privacy > Location Services."),
                                 dismissButton: .default(Text("OK")))
                case .locationRestricted:
                    return Alert(title: Text("Location Access Restricted"),
                                 message: Text("Location access is restricted. Please contact your device administrator or check parental controls."),
                                 dismissButton: .default(Text("OK")))
                default:
                    return Alert(title: Text("Unknown Error"), message: nil, dismissButton: .default(Text("OK")))
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
                case .denied:
                    self.currentAlert = .locationDenied
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 2 seconds delay
                        self.appState = .permissionDenied
                    }
                default:
                    break
                }
            }
            .onReceive(locationManager.locationDeniedErrorPublisher) { _ in
                print("Received location denied from publisher.")
                self.currentAlert = .locationDenied
            }
            .onReceive(locationManager.locationRestrictedErrorPublisher) { _ in
                print("Received location restricted from publisher.")
                self.currentAlert = .locationRestricted
            }
        }
    }
}




