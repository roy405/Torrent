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
        ZStack { // Using ZStack to potentially add gradient backgrounds or other backgrounds
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing) // Example gradient
                .cornerRadius(12)

            HStack(spacing: 20) {
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80) // Making the image slightly larger
                } else if isLoading {
                    ProgressView() // Using a loader while fetching the image
                        .frame(width: 80, height: 80)
                }

                VStack(alignment: .leading, spacing: 8) { // Consistent spacing
                    Text("\(currentWeatherViewModel.temperature, specifier: "%.1f")°C")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .id(currentWeatherViewModel.temperature)
                    Text(currentWeatherViewModel.conditionText)
                        .font(.title2)
                        .fontWeight(.light)
                    Text(currentWeatherViewModel.location)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5) // Adding shadows for depth
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
