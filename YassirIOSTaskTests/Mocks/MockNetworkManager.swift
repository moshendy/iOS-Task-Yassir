//
//  MockNetworkManager.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 24/08/2025.
//

import Foundation
import Combine
import Alamofire
@testable import iOSTaskYassir

// MARK: - Mock Network Manager
class MockNetworkManager: NetworkManager {
    
    // MARK: - Mock Properties
    var shouldFail: Bool = false
    var mockResponse: Any?
    var mockError: AppError?
    
    // MARK: - Mock Methods
    override func request<T: Codable>(_ url: String, method: HTTPMethod = .get, parameters: Parameters? = nil) -> AnyPublisher<T, AppError> {
        if shouldFail {
            return Fail(error: mockError ?? .networkError("Mock network failure"))
                .eraseToAnyPublisher()
        }
        
        if let mockResponse = mockResponse as? T {
            return Just(mockResponse)
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        }
        
        // Default mock response
        return Fail(error: .networkError("No mock response configured"))
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Setup Methods
    func setMockResponse<T>(_ response: T) {
        mockResponse = response
    }
    
    func setMockError(_ error: AppError) {
        mockError = error
        shouldFail = true
    }
    
    func setConnected(_ connected: Bool) {
        // Override the published property
        super.isConnected = connected
    }
    
    func reset() {
        shouldFail = false
        mockResponse = nil
        mockError = nil
        super.isConnected = true
    }
}
