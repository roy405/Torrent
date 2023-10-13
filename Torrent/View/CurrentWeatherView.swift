//
//  CurrentWeather.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import SwiftUI

// View for real time weather at the top of the dashboard
// Host view is the RealTimeWeatherView
struct CurrentWeatherView: View {
    @ObservedObject var currentWeatherViewModel: CurrentWeatherViewModel
    @State private var uiImage: UIImage?
    @State private var isLoading: Bool = true // To indicate loading
    @State private var dataUpdated: Bool = false
    @State private var showErrorAlert: Bool = false
    
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)

            HStack(spacing: 20) {
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                } else {
                    if isLoading {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(ProgressView()) // Overlaying ProgressView on placeholder
                    } else {
                        Image(systemName: "cloud")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(currentWeatherViewModel.temperature, specifier: "%.1f")°C")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(currentWeatherViewModel.conditionText)
                        .font(.title2)
                        .fontWeight(.medium)
                    Text(currentWeatherViewModel.location)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"),
                  message: Text(currentWeatherViewModel.error?.localizedDescription ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear {
            isLoading = true
            currentWeatherViewModel.fetchWeatherFromCoreData()
            self.loadWeatherIcon()
        }
        .onReceive(currentWeatherViewModel.$temperature) { _ in
            self.loadWeatherIcon()
            self.dataUpdated.toggle()
        }
        .onReceive(currentWeatherViewModel.$error) { error in
            if error != nil {
                showErrorAlert = true
            }
        }
    }

    // Function to load weather icon for the current weather's in user's location
    private func loadWeatherIcon() {
        
        if let currentURLString = currentWeatherViewModel.conditionIconURL?.absoluteString {
            var urlString = currentURLString
            
            if urlString.starts(with: "//") {
                urlString = "https:" + urlString
            }

            if let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.uiImage = image
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
}
