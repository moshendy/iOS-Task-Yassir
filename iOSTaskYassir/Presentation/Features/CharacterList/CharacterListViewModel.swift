//
//  CharacterListViewModel.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 23/08/2025.
//

import Foundation
import Combine
import SwiftUI

class CharacterListViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var characters: [Character] = []
    @Published var isLoadingMore = false
    @Published var searchText = ""
    @Published var hasMorePages = true
    @Published var isSearching = false
    @Published var isOffline = false
    
    // MARK: - Dependencies
    private let getCharactersUseCase: GetCharactersUseCaseProtocol
    private let networkManager: any NetworkManagerProtocol
    private let configuration: RepositoryConfiguration
    
    // MARK: - Private Properties
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    private var previousSearchText = ""
    
    // MARK: - Initialization
    init(
        getCharactersUseCase: GetCharactersUseCaseProtocol = GetCharactersUseCaseFactory.create(),
        networkManager: any NetworkManagerProtocol = NetworkManager.shared,
        configuration: RepositoryConfiguration = .default
    ) {
        self.getCharactersUseCase = getCharactersUseCase
        self.networkManager = networkManager
        self.configuration = configuration
        
        super.init()
        
        setupBindings()
        loadCharacters()
    }
    
    // MARK: - Setup
    internal override func setupBindings() {
        // Handle search text changes with proper filtering
        $searchText
            .dropFirst() // Skip the initial empty value
            .debounce(for: .milliseconds(Int(AppTiming.searchDebounceTime * 1000)), scheduler: DispatchQueue.main)
            .sink { [weak self] currentText in
                self?.handleSearchTextChange(currentText)
            }
            .store(in: &cancellables)
        
        // Monitor network connectivity
        networkManager.isConnectedPublisher
            .sink { [weak self] isConnected in
                self?.isOffline = !isConnected
                // Only show offline message if we're not currently displaying cached search results
                if !isConnected && !self!.isSearching == true {
                    self?.errorMessage = "No internet connection. Showing cached data."
                } else if isConnected {
                    // Clear offline error when connection is restored
                    if self?.errorMessage?.contains("No internet connection") == true {
                        self?.errorMessage = nil
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadCharacters() {
        guard !isLoading else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.errorMessage = nil
        }
        currentPage = 1
        
        getCharactersUseCase.execute(page: currentPage, searchQuery: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    // Check if this is a network error and we might have cached data
                    if error.localizedDescription.contains("network") || error.localizedDescription.contains("internet") {
                        self?.errorMessage = "No internet connection. Showing cached data if available."
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            } receiveValue: { [weak self] response in
                self?.characters = response.results
                self?.hasMorePages = response.hasMorePages
                // Clear any error messages when we successfully get results
                if !response.results.isEmpty {
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func loadMoreCharacters() {
        guard !isLoadingMore && hasMorePages && !isSearching else { return }
        
        // If offline, show appropriate message
        if isOffline {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Cannot load more characters while offline. Please reconnect to load additional pages."
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingMore = true
        }
        
        getCharactersUseCase.execute(page: currentPage + 1, searchQuery: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingMore = false
                if case .failure(let error) = completion {
                    // Check if this is a network error and we might have cached data
                    if error.localizedDescription.contains("network") || error.localizedDescription.contains("internet") {
                        self?.errorMessage = "Cannot load more characters while offline. Please reconnect to load additional pages."
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            } receiveValue: { [weak self] response in
                self?.currentPage += 1
                self?.characters.append(contentsOf: response.results)
                self?.hasMorePages = response.hasMorePages
                // Clear any error messages when we successfully get results
                if !response.results.isEmpty {
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func refresh() {
        currentPage = 1
        DispatchQueue.main.async { [weak self] in
            self?.isSearching = false
            self?.searchText = ""
            self?.previousSearchText = ""
        }
        loadCharacters()
    }
    
    
    // MARK: - Private Methods
    private func handleSearchTextChange(_ currentText: String) {
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        // If text hasn't changed, don't search again
        if trimmedText == previousSearchText {
            return
        }
        
        // If text is empty, reset to show all characters
        if trimmedText.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.isSearching = false
                self?.currentPage = 1
                self?.previousSearchText = ""
            }
            loadCharacters()
            return
        }
        

        
        // Text has changed and is not empty, perform search
        previousSearchText = trimmedText
        performSearch(trimmedText)
    }
    
    private func performSearch(_ query: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            // Perform search
            currentPage = 1
            DispatchQueue.main.async { [weak self] in
                self?.isSearching = true
                self?.isLoading = true
                self?.errorMessage = nil
            }
            
            getCharactersUseCase.execute(page: currentPage, searchQuery: query)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        // Check if this is a network error and we might have cached data
                        if error.localizedDescription.contains("network") || error.localizedDescription.contains("network") {
                            self?.errorMessage = "Search requires internet connection. Showing cached results if available."
                        } else {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                } receiveValue: { [weak self] response in
                    self?.characters = response.results
                    self?.hasMorePages = response.hasMorePages
                    // Clear any error messages when we successfully get results
                    if !response.results.isEmpty {
                        self?.errorMessage = nil
                    }
                }
                .store(in: &self.cancellables)
        }
    }
}

