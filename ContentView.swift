//
//  ContentView.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isShowingMap = false
    @ObservedObject var recommendationViewModel = RecommendationViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {

            // Now tab
            NavigationView {
                RealTimeWeatherView()
                    .navigationBarTitle("Now", displayMode: .inline)
                    .navigationBarItems(trailing: Button(action: {
                        self.isShowingMap.toggle()
                    }, label: {
                        Image(systemName: "map.fill") // More detailed icon
                            .imageScale(.large) // Appropriate scaling
                            .padding()
                    }))
                    .sheet(isPresented: $isShowingMap) {
                        WeatherMapView(isShowingMap: $isShowingMap)
                    }
            }
            .tabItem {
                VStack {
                    Image(systemName: "sun.max.fill") // Filled version for clarity
                    Text("Now")
                }
            }
            .tag(0)

            // Recommendations tab
            NavigationView {
                RecommendationView(recommendationViewModel: recommendationViewModel)
            }
            .tabItem {
                VStack {
                    Image(systemName: "cloud.sun.fill") // Filled version for clarity
                    Text("Recommendations")
                }
            }
            .tag(1)

            // Real weather feedback tab
            Text("Real Weather Feedback Placeholder")
                .tabItem {
                    VStack {
                        Image(systemName: "cloud.rain.fill") // Filled version for clarity
                        Text("Feedback")
                    }
                }
                .tag(2)
        }
        .accentColor(.blue) // Gives a nice tint to the selected items
    }
}



#Preview {
    ContentView()
}
