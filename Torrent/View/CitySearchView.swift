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
                HStack {
                    Image(systemName: "magnifyingglass")  // System-provided search icon for better recognition
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                    
                    TextField("Search for a city", text: $searchQuery)
                        .padding([.leading, .trailing], 5)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // List of cities
                List(cityViewModel.cities.filter { searchQuery.isEmpty ? true : $0.cityname.contains(searchQuery) }, id: \.id) { city in
                    Button(action: {
                        self.weatherViewModel.fetchWeatherForCity(city.cityname)
                        self.searchQuery = ""
                        self.isShowingCitySearch = false
                    }) {
                        Text(city.cityname)
                            .font(.headline)  // Increased font weight for better readability
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Search Cities", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.isShowingCitySearch = false
            }) {
                Text("Done")
                    .fontWeight(.semibold)
            })  // Added a 'Done' button for easier modal dismissal
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

