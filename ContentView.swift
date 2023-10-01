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
                        Image(systemName: "map") // Placeholder system image for maps
                    }))
                    .sheet(isPresented: $isShowingMap) {
                        WeatherMapView(isShowingMap: $isShowingMap)
                    }
            }
            .tabItem {
                Image(systemName: "sun.max") // You can use a different image
                Text("Now")
            }
            .tag(0)

            NavigationView{
                RecommendationView(recommendationViewModel: recommendationViewModel)
            }
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
