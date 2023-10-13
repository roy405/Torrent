//
//  MockSession.swift
//  Torrent
//
//  Created by Cube on 10/10/23.
//

import Foundation
import Combine

class MockURLSession: URLSession {
    var data: Data?
    var error: Error?
    
    override func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
        return URLSession.DataTaskPublisher(output: (data: data!, response: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!), failure: error!)
    }
}
