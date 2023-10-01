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
    
    init() {
        fetchRecommendations()
    }
    
    func saveRecommendation(id: UUID, dateAndTime: Date, recommendation: String, weatherCondition: String) {
        let recommendation = Recommendation(id: id, dateAndTime: dateAndTime, recommendation: recommendation, weatherCondition: weatherCondition)
        PersistenceController.shared.saveRecommendationToCoreData(recommendation: recommendation)
    }
    
    func fetchRecommendations() {
        self.recommendations = PersistenceController.shared.fetchRecommendations()
    }
}

