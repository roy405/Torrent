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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Use the locationManager from appDelegate
                    appDelegate.locationManager.requestLocationAuthorization()
                }
        }
    }
}
