//
//  SwiftUIView.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI
struct RealTimeWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel = WeatherViewModel()
    @ObservedObject private var imageLoader = ImageLoader()
    
    @State private var isShowingCitySearch: Bool = false

    @ObservedObject var recentWeatherViewModel = RecentWeatherViewModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    self.isShowingCitySearch.toggle()
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .sheet(isPresented: $isShowingCitySearch) {
                    CitySearchView(weatherViewModel: viewModel, isShowingCitySearch: self.$isShowingCitySearch)
                }

                Spacer()
            }
            .padding(.horizontal)

            // List for displaying recent weather data
            List {
                ForEach(recentWeatherViewModel.recentWeatherData, id: \.id) { weatherData in
                    HStack {
                        // Your icon display logic
                        if let image = imageLoader.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }

                        VStack(alignment: .leading) {
                            Text("\(weatherData.cityName), \(weatherData.countryName)")
                                .font(.headline)
                            Text("\(weatherData.temperature, specifier: "%.1f")°C")
                            Text(weatherData.conditionText)
                        }
                    }
                }
                .onDelete(perform: recentWeatherViewModel.deleteWeather)  // <-- Add this line for deletion
            }

            Spacer()
        }
        .onAppear {
            if let url = viewModel.conditionIconURL {
                imageLoader.load(url: url)
            }
            recentWeatherViewModel.fetchRecentWeatherFromCoreData()
        }
    }
}



struct RealTimeWeatherView_Preview: PreviewProvider {
    static var previews: some View {
        RealTimeWeatherView()
    }
}



