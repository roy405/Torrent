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
    @Published var error: String?  // <- This will hold the error message

    init() {
        fetchTodaysRecommendation()
    }
    
    func saveRecommendation(id: UUID, dateAndTime: Date, recommendation: String, weatherCondition: String) {
        let recommendation = Recommendation(id: id, dateAndTime: dateAndTime, recommendation: recommendation, weatherCondition: weatherCondition)
        let result = PersistenceController.shared.saveRecommendationToCoreData(recommendation: recommendation)
        switch result {
        case .success():
            print("Successfully saved recommendation.")
        case .failure(let error):
            print("Error saving recommendation: \(error)")
            self.error = error.localizedDescription  // <- Save the error here
        }
    }
        
    func fetchTodaysRecommendation() {
        let result = PersistenceController.shared.fetchRecommendationsForToday()
        switch result {
        case .success(let recommendations):
            if let recommendationToday = recommendations.first {
                todaysRecommendation = recommendationToday
            }
        case .failure(let error):
            print("Error fetching today's recommendation: \(error)")
            self.error = error.localizedDescription  // <- Save the error here
        }
    }
}


