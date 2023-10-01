//
//  CurrentWeather.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//
import SwiftUI

// MARK: - Current Weather Component
struct CurrentWeatherComponent: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        HStack {
            // Display an icon representing the weather condition
            if let url = viewModel.conditionIconURL, let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading) {
                Text("\(viewModel.temperature, specifier: "%.1f")°C")
                    .font(.headline)
                Text(viewModel.conditionText)
                    .font(.subheadline)
                Text(viewModel.location)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
