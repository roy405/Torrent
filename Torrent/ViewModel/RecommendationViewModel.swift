//
//  RecommendationViewModel.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import Foundation
import CoreData

// ViewModel for managing Recommendation-related data and operations.
/// ViewModel responsible for managing recommendations.
class RecommendationViewModel: ObservableObject {
    
    //List of all published variables.
    @Published var recommendations: [Recommendation] = []
    @Published var todaysRecommendation: Recommendation?
    @Published var error: String?

    // Initializes the view model and fetches today's recommendation.
    init() {
        fetchTodaysRecommendation()
    }
    
    // Saves a recommendation into the Core Data store.
    func saveRecommendation(id: UUID, dateAndTime: Date, recommendation: String, weatherCondition: String) {
        let recommendation = Recommendation(id: id, dateAndTime: dateAndTime, recommendation: recommendation, weatherCondition: weatherCondition)
        let result = PersistenceController.shared.saveRecommendationToCoreData(recommendation: recommendation)
        switch result {
        case .success():
            print("Successfully saved recommendation.")
        case .failure(let error):
            print("Error saving recommendation: \(error)")
            self.error = error.localizedDescription  // Capture the error for potential UI feedback.
        }
    }
        
    // Fetches the recommendation for the current day.
    func fetchTodaysRecommendation() {
        let result = PersistenceController.shared.fetchRecommendationsForToday()
        switch result {
        case .success(let recommendations):
            // Set the first recommendation of the day, if available.
            if let recommendationToday = recommendations.first {
                todaysRecommendation = recommendationToday
            }
        case .failure(let error):
            print("Error fetching today's recommendation: \(error)")
            self.error = error.localizedDescription  // Capture the error for potential UI feedback.
        }
    }
}



