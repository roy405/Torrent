//
//  FeedBackFormView.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import SwiftUI

struct FeedbackFormView: View {
    @State private var feedbackText: String = ""
    @Binding var isShowingForm: Bool
    //@ObservedObject var feedbackViewModel: FeedbackViewModel // Assuming you have a FeedbackViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Submit Your Feedback")
                .font(.largeTitle)
                .bold()
            
            TextEditor(text: $feedbackText)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Button("Submit") {
                //feedbackViewModel.saveFeedback(feedbackText: feedbackText)
                isShowingForm.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}


