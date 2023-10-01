//
//  CitySearchView.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI

struct CitySearchView: View {
    @ObservedObject var cityViewModel: CityViewModel = CityViewModel(context: PersistenceController.shared.container.viewContext)
    @ObservedObject var weatherViewModel: WeatherViewModel
    
    @State private var searchQuery: String = ""
    @Binding var isShowingCitySearch: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search Bar
                TextField("Search for a city", text: $searchQuery)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // List of cities
                List(cityViewModel.cities.filter { searchQuery.isEmpty ? true : $0.cityname.contains(searchQuery) }, id: \.id) { city in
                    Button(action: {
                        self.weatherViewModel.fetchWeatherForCity(city.cityname)
                        self.searchQuery = ""
                        self.isShowingCitySearch = false
                    }) {
                        Text(city.cityname)
                            .font(.headline)  // Increase font weight
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Search Cities", displayMode: .inline)
        }
        .onAppear {
            cityViewModel.fetchCitiesFromCoreData()
        }
    }
}

struct CitySearchView_Previews: PreviewProvider {
    static var previews: some View {
        CitySearchView(weatherViewModel: WeatherViewModel(), isShowingCitySearch: .constant(true))
    }
}
