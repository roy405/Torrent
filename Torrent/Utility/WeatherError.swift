//
//  WeatherError.swift
//  Torrent
//
//  Created by Cube on 10/8/23.
//

import Foundation

// Enum dedicated to Potential Weather Errors
enum WeatherError: LocalizedError {
    case urlCreation
    case apiRequest
    case decoding
    case coreData
    case weatherFeedbackFetchError
    case weatherRecommendationFetchError
    case weatherCityFetchError
    case weatherCityMapFetchError
    
    var errorDescription: String? {
        switch self {
        case .urlCreation: return "Failed to create the API request URL."
        case .apiRequest: return "Failed to fetch data from the Weather API."
        case .decoding: return "Failed to decode the weather data."
        case .coreData: return "Failed to save or fetch from Core Data."
        case .weatherFeedbackFetchError: return "Failed to fetch weather for feedback."
        case .weatherRecommendationFetchError: return "Failed to fetch weather for recommendation."
        case .weatherCityFetchError: return "Failed to fetch weather for City list."
        case .weatherCityMapFetchError: return "Failed to fetch weather for city from map. "
        }
    }
}
