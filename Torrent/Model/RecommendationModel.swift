//
//  RecommendationModel.swift
//  Torrent
//
//  Created by Cube on 10/1/23.
//

import Foundation

struct Recommendation {
    public var id: UUID
    public var dateAndTime: Date
    public var recommendation: String
    public var weatherCondition: String
}
