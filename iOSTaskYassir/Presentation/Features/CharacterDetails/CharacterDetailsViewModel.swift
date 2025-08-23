//
//  CharacterDetailsViewModel.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 23/08/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CharacterDetailsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var character: Character?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let getCharacterDetailsUseCase: GetCharacterDetailsUseCaseProtocol
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        character: Character? = nil,
        getCharacterDetailsUseCase: GetCharacterDetailsUseCaseProtocol = GetCharacterDetailsUseCaseFactory.create()
    ) {
        self.character = character
        self.getCharacterDetailsUseCase = getCharacterDetailsUseCase
        
        if character == nil {
            // This should not happen in normal flow, but handle it gracefully
            errorMessage = "No character data available"
        }
    }
    
    // MARK: - Public Methods
    func loadCharacterDetails(id: CharacterID) {
        guard character == nil else { return }
        
        isLoading = true
        errorMessage = nil
        
        getCharacterDetailsUseCase.execute(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] character in
                self?.character = character
            }
            .store(in: &cancellables)
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - ViewModel Factory
class CharacterDetailsViewModelFactory {
    @MainActor static func create(character: Character? = nil) -> CharacterDetailsViewModel {
        return CharacterDetailsViewModel(character: character)
    }
}
