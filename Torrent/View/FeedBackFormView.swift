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
    @State private var isFormSubmitted: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Location").font(.headline)) {
                    TextField("City", text: $city)
                    TextField("Country", text: $country)
                }

                Section(header: Text("Reported Weather").font(.headline)) {
                    HStack {
                        Text("Temperature")
                        Spacer()
                        TextField("", value: $reportedTemperature, formatter: NumberFormatter())
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Condition")
                        Spacer()
                        TextField("", text: $reportedCondition)
                            .multilineTextAlignment(.trailing)
                    }
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
                                         isFormSubmitted = true
                                         presentationMode.wrappedValue.dismiss()
                                     }                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("New Feedback")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"),
                      message: Text(feedbackViewModel.errorMessage ?? "Unknown error"),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $isFormSubmitted) {
                Alert(title: Text("Success"),
                      message: Text("Your feedback has been submitted!"),
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
