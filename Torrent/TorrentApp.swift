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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
