//
//  RecommendationViewModel.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import Foundation
import CoreData

class RecommendationViewModel: ObservableObject {
    
    @Published var recommendations: [Recommendation] = []
    @Published var todaysRecommendation: Recommendation?

    init() {
        fetchTodaysRecommendation()
    }
    
    func saveRecommendation(id: UUID, dateAndTime: Date, recommendation: String, weatherCondition: String) {
        let recommendation = Recommendation(id: id, dateAndTime: dateAndTime, recommendation: recommendation, weatherCondition: weatherCondition)
        PersistenceController.shared.saveRecommendationToCoreData(recommendation: recommendation)
    }
    
    func fetchRecommendations() {
        self.recommendations = PersistenceController.shared.fetchRecommendations()
    }
    
    func fetchTodaysRecommendation() {
        if let recommendationToday = PersistenceController.shared.fetchRecommendationsForToday().first {
            todaysRecommendation = recommendationToday
            print()
        }
    }
}

