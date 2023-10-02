//
//  AppDelegate.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import UIKit
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
    var locationManager: LocationManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Register the background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.fetchWeather", using: nil) { task in
            self.handleWeatherFetch(task: task as! BGAppRefreshTask)
        }
        
        // Initialize locationManager
        locationManager = LocationManager()
        
        return true
    }
    
    func handleWeatherFetch(task: BGAppRefreshTask) {
        task.expirationHandler = {
            // This block is called when the task is about to be expired.
            // Cancel any outstanding operations for this task.
            task.setTaskCompleted(success: false)
        }
        
        // Call the method to start updating the location
        locationManager.startUpdatingLocation()
        
        // Assuming the fetching of weather based on location takes a max of 10 seconds.
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
            task.setTaskCompleted(success: true)
            
            // Schedule the next background task
            self.scheduleWeatherFetch()
        }
    }
    
    func scheduleWeatherFetch() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.fetchWeather")
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        // Set the hour and minute to 8:00 AM.
        dateComponents.hour = 2
        dateComponents.minute = 10
        
        // Get the next 8:00 AM from now.
        if let today8am = calendar.date(from: dateComponents), Date() > today8am {
            dateComponents.day! += 1
        }
        
        let next8am = calendar.date(from: dateComponents)
        
        request.earliestBeginDate = next8am
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background fetch: \(error)")
        }
    }
}

