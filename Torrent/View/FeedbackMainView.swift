//
//  FeedbackMainView.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import SwiftUI

struct FeedbacksMainView: View {
    @State private var isShowingForm: Bool = false
    //@ObservedObject var feedbackViewModel: FeedbackViewModel = FeedbackViewModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Feedbacks")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    isShowingForm.toggle()
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(.systemBlue))
                }
                .sheet(isPresented: $isShowingForm) {
                    //FeedbackFormView(isShowingForm: $isShowingForm, feedbackViewModel: feedbackViewModel)
                }
            }
            .padding(.horizontal)

            // Embedding the list directly here
//            List(feedbackViewModel.feedbacks, id: \.id) { feedback in
//                Text(feedback.text)
//            }

            Spacer()
        }
    }
}
