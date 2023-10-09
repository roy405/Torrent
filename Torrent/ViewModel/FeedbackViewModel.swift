//
//  FeedbackViewModel.swift
//  Torrent
//
//  Created by Cube on 10/3/23.
//

import Foundation
import CoreData

// ViewModel for managing Feedback-related data and operations.
class FeedbackViewModel: ObservableObject {

    // List of all feedbacks.
    @Published var feedbacks: [FeedbackModel] = []

    // Holds an error message, if any error occurs.
    @Published var errorMessage: String?

    // Saves a feedback to Core Data and updates the list of feedbacks.
    func saveFeedback(feedback: FeedbackModel) {
        switch PersistenceController.shared.saveFeedbackToCoreData(feedback: feedback) {
        case .success():
            // Successful save, hence fetch all feedbacks to refresh the list.
            fetchAllFeedbacks()
        case .failure(let error):
            // Handle the error by setting it to the errorMessage property and printing.
            self.errorMessage = error.localizedDescription
            print("Error saving feedback: \(error)")
        }
    }

    // Fetches all feedbacks from Core Data and updates the published list of feedbacks.
    func fetchAllFeedbacks() {
        switch PersistenceController.shared.fetchAllFeedbacks() {
        case .success(let feedbacksList):
            // Update the list of feedbacks.
            self.feedbacks = feedbacksList
        case .failure(let error):
            // Handle the error by setting it to the errorMessage property and printing.
            self.errorMessage = error.localizedDescription
            print("Error fetching all feedbacks: \(error)")
        }
    }

    // Deletes a specific feedback from Core Data and updates the list of feedbacks.
    func deleteFeedback(feedback: FeedbackModel) {
        switch PersistenceController.shared.deleteFeedback(feedback: feedback) {
        case .success():
            // Successful deletion, hence fetch all feedbacks to refresh the list.
            fetchAllFeedbacks()
        case .failure(let error):
            // Handle the error by setting it to the errorMessage property and printing.
            self.errorMessage = error.localizedDescription
            print("Error deleting feedback: \(error)")
        }
    }
}

