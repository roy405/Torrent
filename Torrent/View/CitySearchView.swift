//
//  CitySearchView.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI

// View to display the list of all cities
struct CitySearchView: View {
    @ObservedObject var cityViewModel: CityViewModel = CityViewModel()
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
                            .font(.headline)
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
            })
        }
        .onAppear {
            cityViewModel.fetchCities()
        }
        .alert(isPresented: Binding<Bool>(
            get: { self.cityViewModel.error != nil },
            set: { _ in self.cityViewModel.error = nil }  // Reset the error once it's been shown
        )) {
            Alert(
                title: Text("Error"),
                message: Text(cityViewModel.error?.localizedDescription ?? "Unknown Error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}


struct CitySearchView_Previews: PreviewProvider {
    static var previews: some View {
        CitySearchView(weatherViewModel: WeatherViewModel(), isShowingCitySearch: .constant(true))
    }
}

