//
//  RecommendationView.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import SwiftUI

struct RecommendationView: View {
    @ObservedObject var recommendationViewModel: RecommendationViewModel

    var body: some View {
        NavigationView {
            VStack {
                if let todaysRec = recommendationViewModel.todaysRecommendation {
                    VStack(spacing: 20) {
                        Text("Today's Recommendation")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom)
                        
                        recommendationRow(recommendation: todaysRec)
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
            .navigationBarTitle("Recommendation", displayMode: .inline)
        }
        .onAppear {
            recommendationViewModel.fetchTodaysRecommendation()
        }
    }

    func recommendationRow(recommendation: Recommendation) -> some View {
        VStack(alignment: .leading, spacing: 24) {  // Increased spacing
            Text(recommendation.recommendation)
                .font(.title2)
            
            Image(systemName: "cloud")
                .resizable()
                .frame(width: 36, height: 36)  // Increased size
                .foregroundColor(Color(.systemBlue))
                .padding(.bottom)

            Text(recommendation.weatherCondition)
                .font(.headline)

            Text("\(recommendation.dateAndTime, style: .date)")
                .font(.subheadline)
                .foregroundColor(Color.secondary)
        }
        .padding(.vertical, 30) // Increased vertical padding for a taller card
        .frame(maxWidth: .infinity)  // Allows the card to take up maximum horizontal space
        .background(Color(.secondarySystemBackground)) // A subtle background color
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5) // Giving depth using shadow
        .padding(.horizontal)
    }
}


