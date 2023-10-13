//
//  SwiftUIView.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import SwiftUI

// View for the main Dashboard or Landing page of the App.
struct RealTimeWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel = WeatherViewModel()
    @State private var isShowingCitySearch: Bool = false
    @ObservedObject var recentWeatherViewModel = RecentWeatherViewModel()
    @ObservedObject var currentWeatherViewModel = CurrentWeatherViewModel()
    @ObservedObject var forecastViewModel = ForecastViewModel(persistenceController: PersistenceController())
    @State private var imagesDict: [UUID: UIImage] = [:] // Dictionary to hold images
    
    
    
    var showErrorAlert: Binding<Bool> {
        Binding<Bool>(
            get: { self.recentWeatherViewModel.lastError != nil },
            set: { if !$0 { self.recentWeatherViewModel.lastError = nil } }
        )
    }
    
    var showWeatherErrorAlert: Binding<Bool> {
        Binding<Bool>(
            get: { self.viewModel.currentError != nil },
            set: { if !$0 { self.viewModel.currentError = nil } }
        )
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                self.landscapeLayout
            } else {
                self.portraitLayout
            }
        }
        .onAppear {
            recentWeatherViewModel.fetchRecentWeatherFromCoreData()
            forecastViewModel.fetchLatestForecastFromCoreData()
        }
        .navigationTitle("Real-Time Weather")
        .alert(isPresented: showErrorAlert) {
            Alert(title: Text("Error"),
                  message: Text(recentWeatherViewModel.lastError?.errorDescription ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: showWeatherErrorAlert) {
            Alert(title: Text("Error"),
                  message: Text(viewModel.currentError?.errorDescription ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    // Portrait Layout
    var portraitLayout: some View {
        VStack(spacing: 20) {
            CurrentWeatherView(currentWeatherViewModel: currentWeatherViewModel)
                .padding(.horizontal)
            HStack(spacing: 20) {
                ForEach(forecastViewModel.forecasts.prefix(3), id: \.date) { forecast in
                    VStack(spacing: 6) {
                        Text(self.formatDate(forecast.date))
                            .font(.headline)
                            .foregroundColor(Color.white)

                        Text("max:\(forecast.maxtemp_c, specifier: "%.1f")°C  min:\(forecast.mintemp_c, specifier: "%.1f")°C")
                            .font(.body)
                            .foregroundColor(Color.white)

                        Text(forecast.conditionText)
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.8))
                            .lineLimit(1)
                            .frame(width: 80) // This ensures text truncation after a fixed width
                    }
                    .frame(width: 100, height: 100) // Fixed frame size for each card
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
                }
            }
            .padding(.top, 15)

            HStack {
                Button(action: {
                    self.isShowingCitySearch.toggle()
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $isShowingCitySearch) {
                    // Lists cities from which if one is selected, the weather of the city is fetched and added
                    // to the list
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
                            // Weather icon
                            Image(uiImage: imagesDict[weatherData.id ?? UUID()] ?? UIImage(systemName: "cloud")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                                .padding(.trailing, 15)

                            // Weather details
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(weatherData.cityName), \(weatherData.countryName)")
                                    .font(.headline)
                                Text("\(weatherData.temperature, specifier: "%.1f")°C")
                                    .font(.subheadline)
                                Text(weatherData.conditionText)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                        .onAppear {
                            self.loadWeatherIcon(from: URL(string: weatherData.iconURL), for: weatherData.id ?? UUID())
                        }
                    }
                    .onDelete(perform: recentWeatherViewModel.deleteWeather)
                }
                .listStyle(PlainListStyle())
            }

            Spacer()
        }
    }
    
    var landscapeLayout: some View {
        HStack {
            VStack {
                CurrentWeatherView(currentWeatherViewModel: currentWeatherViewModel)
                    .padding(.horizontal)
                HStack(spacing: 20) {
                    //HSTACK CONTENT FOR FORECASTS
                    ForEach(forecastViewModel.forecasts.prefix(3), id: \.date) { forecast in
                        VStack(spacing: 6) {
                            Text(self.formatDate(forecast.date))
                                .font(.headline)
                                .foregroundColor(Color.white)

                            Text("max:\(forecast.maxtemp_c, specifier: "%.1f")°C  min:\(forecast.mintemp_c, specifier: "%.1f")°C")
                                .font(.body)
                                .foregroundColor(Color.white)

                            Text(forecast.conditionText)
                                .font(.caption)
                                .foregroundColor(Color.white.opacity(0.8))
                                .lineLimit(1)
                                .frame(width: 80) // This ensures text truncation after a fixed width
                        }
                        .frame(width: 100, height: 100) // Fixed frame size for each card
                        .padding(.horizontal, 5)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
                    }
                }
                .padding(.top, 15)

            }
            .padding()

            VStack {
                HStack {
                    Button(action: {
                        self.isShowingCitySearch.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $isShowingCitySearch) {
                        // Lists cities from which if one is selected, the weather of the city is fetched and added
                        // to the list
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
                                // Weather icon
                                Image(uiImage: imagesDict[weatherData.id ?? UUID()] ?? UIImage(systemName: "cloud")!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    .padding(.trailing, 15)

                                // Weather details
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("\(weatherData.cityName), \(weatherData.countryName)")
                                        .font(.headline)
                                    Text("\(weatherData.temperature, specifier: "%.1f")°C")
                                        .font(.subheadline)
                                    Text(weatherData.conditionText)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 8)
                            .onAppear {
                                self.loadWeatherIcon(from: URL(string: weatherData.iconURL), for: weatherData.id ?? UUID())
                            }
                        }
                        .onDelete(perform: recentWeatherViewModel.deleteWeather)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding()
        }
    }
    
    // Function to load the Icon for cities added to list
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
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"  // Format: "Mon, Jan 1"
        return formatter.string(from: date)
    }
    
    private func debugPrint<T>(_ value: T) -> some View {
        // This will print the value every time the body is recomputed
        Swift.print("ezmangaming\(value)")
        return EmptyView() // Returns an empty view so it doesn't affect the UI
    }
}

struct RealTimeWeatherView_Preview: PreviewProvider {
    static var previews: some View {
        RealTimeWeatherView()
    }
}

