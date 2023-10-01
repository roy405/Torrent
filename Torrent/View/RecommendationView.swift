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
            List(recommendationViewModel.recommendations, id: \.id) { recommendation in
                VStack(alignment: .leading, spacing: 8) {
                    Text(recommendation.recommendation)
                        .font(.headline)

                    HStack {
                        Image(systemName: "cloud") // A sample system icon. You can change this based on the weather condition or any other relevant metric.
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        Text(recommendation.weatherCondition)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Text("\(recommendation.dateAndTime, style: .date)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            .navigationBarTitle("Recommendations", displayMode: .inline)
            .onAppear {
                recommendationViewModel.fetchRecommendations()
            }
        }
    }
}

