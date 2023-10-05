//
//  AppState.swift
//  Torrent
//
//  Created by Cube on 10/2/23.
//

import Foundation

// Enum that determines the state of the App
enum AppState {
    case waitingForPermission
    case permissionDenied
    case ready
}
