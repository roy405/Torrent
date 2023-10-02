//
//  SwiftUIView.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI

struct RealTimeWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel = WeatherViewModel()
    @State private var isShowingCitySearch: Bool = false
    @ObservedObject var recentWeatherViewModel = RecentWeatherViewModel()
    @ObservedObject var currentWeatherViewModel = CurrentWeatherViewModel()
    @State private var imagesDict: [UUID: UIImage] = [:] // Dictionary to hold images

    var body: some View {
        VStack(spacing: 20) {
            CurrentWeatherView(currentWeatherViewModel: currentWeatherViewModel)
                .padding(.horizontal)

            HStack {
                Button(action: {
                    self.isShowingCitySearch.toggle()
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $isShowingCitySearch) {
                    CitySearchView(weatherViewModel: viewModel, isShowingCitySearch: self.$isShowingCitySearch)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.horizontal)

            if recentWeatherViewModel.recentWeatherData.isEmpty {
                ProgressView("Please add a city to view Current Weather...")
                    .padding(.top, 50)
            } else {
                List {
                    ForEach(recentWeatherViewModel.recentWeatherData, id: \.id) { weatherData in
                        HStack {
                            if let image = imagesDict[weatherData.id ?? UUID()] {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "photo.fill") // Placeholder image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    .opacity(0.5)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("\(weatherData.cityName), \(weatherData.countryName)")
                                    .font(.headline)
                                Text("\(weatherData.temperature, specifier: "%.1f")°C")
                                Text(weatherData.conditionText)
                            }
                        }
                        .padding(.vertical, 8)
                        .onAppear {
                            self.loadWeatherIcon(from: URL(string: weatherData.iconURL), for: weatherData.id ?? UUID())
                        }
                    }
                    .onDelete(perform: recentWeatherViewModel.deleteWeather)
                }
            }
            
            Spacer()
        }
        .onAppear {
            recentWeatherViewModel.fetchRecentWeatherFromCoreData()
        }
        .navigationTitle("Real-Time Weather")
    }
    
    private func loadWeatherIcon(from url: URL?, for id: UUID) {
        guard let validURL = url else { return }
        var modifiedURL = validURL
        if validURL.absoluteString.starts(with: "//") {
            if let secureURL = URL(string: "https:" + validURL.absoluteString) {
                modifiedURL = secureURL
            }
        }

        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: modifiedURL), let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.imagesDict[id] = image
                }
            }
        }
    }
}

struct RealTimeWeatherView_Preview: PreviewProvider {
    static var previews: some View {
        RealTimeWeatherView()
    }
}

