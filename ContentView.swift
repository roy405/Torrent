//
//  ContentView.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

        var body: some View {
            TabView(selection: $selectedTab) {
                // Now tab
                NavigationView {
                    RealTimeWeatherView()
                        .navigationBarTitle("Now", displayMode: .inline)
                        .navigationBarItems(trailing: Button(action: {
                            // Handle navigation to weather maps here
                        }, label: {
                            Image(systemName: "map") // Placeholder system image for maps
                        }))
                }
                .tabItem {
                    Image(systemName: "sun.max") // You can use a different image
                    Text("Now")
                }
                .tag(0)

                // Weather Recommendations tab
                Text("Weather Recommendations Placeholder")
                    .tabItem {
                        Image(systemName: "cloud.sun") // Placeholder image, choose an appropriate one
                        Text("Recommendations")
                    }
                    .tag(1)

                // Real weather feedback tab
                Text("Real Weather Feedback Placeholder")
                    .tabItem {
                        Image(systemName: "cloud.rain") // Placeholder image, choose an appropriate one
                        Text("Feedback")
                    }
                    .tag(2)
            }
        }
    }

#Preview {
    ContentView()
}
