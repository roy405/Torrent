//
//  FeedbackMainView.swift
//  Torrent
//
//  Created by Cube on 10/3/23.
//

import SwiftUI

// View for the main Feedback list view
struct FeedbackMainView: View {
    @ObservedObject var feedbackViewModel = FeedbackViewModel()
    @State private var showFeedbackForm = false
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(feedbackViewModel.feedbacks) { feedback in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("City:").bold()
                            Spacer()
                            Text("\(feedback.city)")
                        }
                        HStack {
                            Text("Country:").bold()
                            Spacer()
                            Text("\(feedback.country)")
                        }
                        HStack {
                            Text("Reported Temp:").bold()
                            Spacer()
                            Text(String(format: "%.2f", feedback.reportedTemperature) + "°")
                        }
                        HStack {
                            Text("Reported Condition:").bold()
                            Spacer()
                            Text("\(feedback.reportedCondition)")
                        }
                        HStack {
                            Text("Actual Temp:").bold()
                            Spacer()
                            Text(String(format: "%.2f", feedback.actualTemperature) + "°")
                        }
                        HStack {
                            Text("Actual Condition:").bold()
                            Spacer()
                            Text("\(feedback.actualCondition)")
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: deleteFeedback)
            }
            .navigationTitle("Feedbacks History")
            .navigationBarItems(trailing: Button(action: {
                showFeedbackForm.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showFeedbackForm) {
                // Calling Feedback Form
                FeedbackFormView(feedbackViewModel: feedbackViewModel)
            }
            .onAppear {
                feedbackViewModel.fetchAllFeedbacks()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"),
                      message: Text(feedbackViewModel.errorMessage ?? "Unknown error"),
                      dismissButton: .default(Text("OK")))
            }
        }
        .onReceive(feedbackViewModel.$errorMessage) { errorMessage in
            if errorMessage != nil {
                showAlert = true
            }
        }
    }

    // Implementing the delete functionality
    func deleteFeedback(at offsets: IndexSet) {
        // Extract feedback to delete from the index set
        let feedbacksToDelete = offsets.map { feedbackViewModel.feedbacks[$0] }
        for feedback in feedbacksToDelete {
            feedbackViewModel.deleteFeedback(feedback: feedback)
        }
    }
}



#Preview {
    FeedbackMainView()
}
