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
        VStack(spacing: 20) {
            List(cityViewModel.cities, id: \.id) { city in
                Button(action: {
                    self.weatherViewModel.fetchWeatherForCity(city.cityname)
                    self.searchQuery = ""
                    self.isShowingCitySearch = false
                }) {
                    Text(city.cityname)
                }
            }
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
