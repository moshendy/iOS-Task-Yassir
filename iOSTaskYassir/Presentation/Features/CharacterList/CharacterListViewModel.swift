import Foundation
import Combine
import SwiftUI

@MainActor
class CharacterListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var characters: [Character] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var searchText = ""
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    @Published var isSearching = false
    @Published var isOffline = false
    
    // MARK: - Dependencies
    private let getCharactersUseCase: GetCharactersUseCaseProtocol
    private let networkManager: NetworkManager
    private let configuration: RepositoryConfiguration
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(
        getCharactersUseCase: GetCharactersUseCaseProtocol = GetCharactersUseCaseFactory.create(),
        networkManager: NetworkManager = NetworkManager.shared,
        configuration: RepositoryConfiguration = .default
    ) {
        self.getCharactersUseCase = getCharactersUseCase
        self.networkManager = networkManager
        self.configuration = configuration
        
        setupBindings()
        loadCharacters()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Debounce search text changes
        $searchText
            .debounce(for: .milliseconds(Int(AppConfiguration.UI.searchDebounceTime * 1000)), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.performSearch(searchText)
            }
            .store(in: &cancellables)
        
        // Monitor network connectivity
        networkManager.$isConnected
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
        
        isLoading = true
        errorMessage = nil
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
            errorMessage = "Cannot load more characters while offline. Please reconnect to load additional pages."
            return
        }
        
        isLoadingMore = true
        
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
        isSearching = false
        searchText = ""
        loadCharacters()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func performSearch(_ query: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            if query.isEmpty {
                // Reset to first page and load all characters
                currentPage = 1
                isSearching = false
                loadCharacters()
            } else {
                // Perform search
                currentPage = 1
                isSearching = true
                isLoading = true
                errorMessage = nil
                
                getCharactersUseCase.execute(page: currentPage, searchQuery: query)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            // Check if this is a network error and we might have cached data
                            if error.localizedDescription.contains("network") || error.localizedDescription.contains("internet") {
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
}

// MARK: - ViewModel Factory
class CharacterListViewModelFactory {
    @MainActor static func create() -> CharacterListViewModel {
        return CharacterListViewModel()
    }
}
