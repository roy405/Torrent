//
//  FeedbackFormView.swift
//  Torrent
//
//  Created by Cube on 10/3/23.
//

import SwiftUI

// Feedback form view that allows users to enter feedback and upon
// Submit subsequently brings in the current weather based on the city entered
struct FeedbackFormView: View {
    @ObservedObject var feedbackViewModel: FeedbackViewModel
    @ObservedObject var weatherViewModel = WeatherViewModel() 
    @Environment(\.presentationMode) var presentationMode

    @State private var city: String = ""
    @State private var country: String = ""
    @State private var reportedTemperature: Double = 0
    @State private var reportedCondition: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Location")) {
                    TextField("City", text: $city)
                    TextField("Country", text: $country)
                }

                Section(header: Text("Reported Weather")) {
                    TextField("Temperature", value: $reportedTemperature, formatter: NumberFormatter())
                    TextField("Condition", text: $reportedCondition)
                }

                Button("Submit") {
                    weatherViewModel.fetchWeatherForFeedback(city) {
                        let actualTemp = self.weatherViewModel.temperature
                        let actualCond = self.weatherViewModel.conditionText

                        let feedback = FeedbackModel(id: UUID(),
                                                    city: city,
                                                     country: country,
                                                     reportedTemperature: reportedTemperature,
                                                     reportedCondition: reportedCondition,
                                                     actualTemperature: actualTemp,
                                                     actualCondition: actualCond)
                        feedbackViewModel.saveFeedback(feedback: feedback)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("New Feedback")
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
    FeedbackFormView(feedbackViewModel: FeedbackViewModel())
}
