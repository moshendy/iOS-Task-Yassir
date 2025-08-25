//
//  MockRealmManager.swift
//  iOSTaskYassirTests
//
//  Created by Mohamed Shendy on 25/08/2025.
//

import Foundation
import Combine
@testable import iOSTaskYassir

// MARK: - Mock Realm Manager
class MockRealmManager: RealmManagerProtocol {
    private var mockCharacters: [Character] = []
    var saveCharactersCalled = false
    
    func setMockCharacters(_ characters: [Character]) {
        mockCharacters = characters
    }
    
    func getCharacters() -> AnyPublisher<[Character], AppError> {
        return Just(mockCharacters).setFailureType(to: AppError.self).eraseToAnyPublisher()
    }
    
    func saveCharacters(_ characters: [Character]) -> AnyPublisher<Void, AppError> {
        saveCharactersCalled = true
        mockCharacters = characters
        return Just(()).setFailureType(to: AppError.self).eraseToAnyPublisher()
    }
    
    func clearCache() -> AnyPublisher<Void, AppError> {
        mockCharacters.removeAll()
        return Just(()).setFailureType(to: AppError.self).eraseToAnyPublisher()
    }
    
    func isCacheValid() -> AnyPublisher<Bool, AppError> {
        return Just(true).setFailureType(to: AppError.self).eraseToAnyPublisher()
    }
}
