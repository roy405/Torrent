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
            List(feedbackViewModel.feedbacks) { feedback in
                VStack(alignment: .leading) {
                    Text("City: ").bold() + Text("\(feedback.city)")
                    Text("Country: ").bold() + Text("\(feedback.country)")
                    Text("Reported Temperature: ").bold() + Text("\(feedback.reportedTemperature)°")
                    Text("Reported Condition: ").bold() + Text("\(feedback.reportedCondition)")
                    Text("Actual Temperature: ").bold() + Text(String(format: "%.2f", feedback.actualTemperature) + "°")
                    Text("Actual Condition: ").bold() + Text("\(feedback.actualCondition)")

                }
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
}


#Preview {
    FeedbackMainView()
}
