//
//  FeedbackModel.swift
//  Torrent
//
//  Created by Cube on 10/3/23.
//

import Foundation

// Feedback Model to map Feedback data from weather and user input
struct FeedbackModel: Identifiable{
    var id: UUID
    var city: String
    var country: String
    var reportedTemperature: Double
    var reportedCondition: String
    var actualTemperature: Double
    var actualCondition: String
}
