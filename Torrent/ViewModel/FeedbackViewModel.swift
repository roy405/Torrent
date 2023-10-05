//
//  FeedbackViewModel.swift
//  Torrent
//
//  Created by Cube on 10/3/23.
//

import Foundation
import CoreData

class FeedbackViewModel: ObservableObject {
    @Published var feedbacks: [FeedbackModel] = []
    @Published var errorMessage: String?

    
    let persistenceController = PersistenceController.shared

    func saveFeedback(feedback: FeedbackModel) {
        switch persistenceController.saveFeedbackToCoreData(feedback: feedback) {
        case .success():
            // After saving, update the feedbacks array
            fetchAllFeedbacks()
        case .failure(let error):
            // Handle or print the error
            self.errorMessage = error.localizedDescription
            print("Error saving feedback: \(error)")
        }
    }

    func fetchAllFeedbacks() {
        switch persistenceController.fetchAllFeedbacks() {
        case .success(let feedbacksList):
            self.feedbacks = feedbacksList
        case .failure(let error):
            // Handle or print the error
            self.errorMessage = error.localizedDescription
            print("Error fetching all feedbacks: \(error)")
        }
    }


    // If you also want to use the delete feedback function
    func deleteFeedback(feedback: FeedbackModel) {
        switch persistenceController.deleteFeedback(feedback: feedback) {
        case .success():
            // After deleting, you might want to update the feedbacks array again
            fetchAllFeedbacks()
        case .failure(let error):
            // Handle or print the error
            self.errorMessage = error.localizedDescription
            print("Error deleting feedback: \(error)")
        }
    }
}
