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
class CharacterDetailsViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var character: Character?
    
    // MARK: - Dependencies
    private let getCharacterDetailsUseCase: GetCharacterDetailsUseCaseProtocol
    
    // MARK: - Initialization
    init(
        character: Character? = nil,
        getCharacterDetailsUseCase: GetCharacterDetailsUseCaseProtocol = GetCharacterDetailsUseCaseFactory.create()
    ) {
        self.character = character
        self.getCharacterDetailsUseCase = getCharacterDetailsUseCase
        
        super.init()
        
        if character == nil {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "No character data available"
            }
        }
    }
    
    // MARK: - Public Methods
    func loadCharacterDetails(id: CharacterID) {
        guard character == nil else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.errorMessage = nil
        }
        
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
    
}

// MARK: - ViewModel Factory
class CharacterDetailsViewModelFactory {
    @MainActor static func create(character: Character? = nil) -> CharacterDetailsViewModel {
        return CharacterDetailsViewModel(character: character)
    }
}
