//
//  RecommendationView.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import SwiftUI

// The view for recommendations
struct RecommendationView: View {
    @ObservedObject var recommendationViewModel: RecommendationViewModel

    var body: some View {
           VStack {
               if let todaysRec = recommendationViewModel.todaysRecommendation {
                   VStack() {
                       Text("Today's Recommendation")
                           .font(.largeTitle)
                           .fontWeight(.bold)
                           .padding(.bottom)
                       
                       recommendationCard(recommendation: todaysRec)
                   }
               } else {
                   Text("No recommendation available for today.")
                       .font(.headline)
                       .foregroundColor(Color.gray)
               }
               Spacer()
           }
           .padding()
           .background(Color(.systemBackground))
           .onAppear {
               recommendationViewModel.fetchTodaysRecommendation()
           }
           .alert(isPresented: Binding<Bool>(
               get: { self.recommendationViewModel.error != nil },
               set: { _ in self.recommendationViewModel.error = nil }
           )) {
               Alert(title: Text("Error"),
                     message: Text(self.recommendationViewModel.error ?? "Unknown error"),
                     dismissButton: .default(Text("OK")))
           }
       }

    // Separating the Recommendation Card from the main body.
    func recommendationCard(recommendation: Recommendation) -> some View {
        VStack(alignment: .leading, spacing: 24) {  // Increased spacing
            let parts = recommendation.recommendation.split(separator: ". ", maxSplits: 1, omittingEmptySubsequences: false)
            if let firstPart = parts.first {
                Text(firstPart + ".").bold()
                    .font(.title2)
            }
            if parts.count > 1 {
                Text(String(parts[1]))
                    .font(.title2)
            }
            
            Image(systemName: weatherIcon(forRecommendation: recommendation.recommendation))
                .resizable()
                .scaledToFit()
                .frame(width: 36)
                .foregroundColor(Color(.systemBlue))
                .padding(.bottom)
            Text(recommendation.weatherCondition)
                .font(.headline)

            Text("\(recommendation.dateAndTime, style: .date)")
                .font(.subheadline)
                .foregroundColor(Color.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    // Switch case to use a proper icon from Apple's SF icons based on the recommendations retrieved from CoreData
    func weatherIcon(forRecommendation recommendation: String) -> String {
        if recommendation.contains("scorching hot") {
            return "thermometer.sun"
        } else if recommendation.contains("freezing outside") {
            return "snowflake"
        } else if recommendation.contains("umbrella") {
            return "cloud.rain"
        } else if recommendation.contains("sunny day") {
            return "sun.max"
        } else if recommendation.contains("snowing") {
            return "snow"
        } else if recommendation.contains("thunderstorm") {
            return "cloud.bolt.rain"
        } else if recommendation.contains("fog") {
            return "cloud.fog"
        } else if recommendation.contains("overcast") {
            return "cloud"
        } else if recommendation.contains("windy") {
            return "wind"
        } else if recommendation.contains("partly cloudy") {
            return "cloud.sun"
        } else if recommendation.contains("clear") {
            return "sun.max"
        }
        return "questionmark.circle" // Default icon for unanticipated conditions
    }
}


