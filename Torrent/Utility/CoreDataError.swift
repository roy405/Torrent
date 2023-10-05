//
//  CoreDataErrors.swift
//  Torrent
//
//  Created by Cube on 10/4/23.
//

import Foundation

// Enum outling all types of errors related to Core Data Persistence actions
enum CoreDataError: LocalizedError {
    case cityFetchError
    case citySaveError
    case recommendationFetchError
    case recommendationSaveError
    case currentWeatherFetchError
    case currentWeatherSaveOrUpdateError
    case feedbackSaveError
    case feedbackFetchError
    case feedbackSaveAfterDeleteError
    case feedbackFetchErrorDuringDeletion
    case recentWeatherForCityFetchError
    case recentWeatherForCityDeleteError
    
    // Switch case for error cases and the respective error descriptions
    var errorDescription: String? {
        switch self {
        case .cityFetchError:
            return "Failed to Fetch City Data."
        case .citySaveError:
            return "Failed to Save City Data."
        case .recommendationFetchError:
            return "Failed to Fetch Today's Recommendation Data."
        case .recommendationSaveError:
            return "Failed to Save Recommendation Data."
        case .currentWeatherFetchError:
            return "Failed to Fetch Current Weather Data."
        case .currentWeatherSaveOrUpdateError:
            return "Failed to Save or Update Current Weather Data."
        case .feedbackSaveError:
            return "Failed to Save Feedback Data."
        case .feedbackFetchError:
            return "Failed to Fetch Feedback Data."
        case .feedbackSaveAfterDeleteError:
            return "Failed to Save Feedback Data after Deleting."
        case .feedbackFetchErrorDuringDeletion:
            return "Failed to Fetch Error During Deletion"
        case .recentWeatherForCityFetchError:
            return "Failed to Fetch Recent Weather for Selected Cities"
        case .recentWeatherForCityDeleteError:
            return "Failed to Delete Recent Weather for Selecte City"
        }
    }
}
