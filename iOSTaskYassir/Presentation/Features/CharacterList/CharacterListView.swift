//
//  CharacterListView.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 23/08/2025.
//
import SwiftUI

struct CharacterListView: View {
    @StateObject private var viewModel = CharacterListViewModelFactory.create()
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Network Status Bar
                if !networkManager.isConnected {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.warning)
                        Text("No internet connection. Showing cached data.")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.warning)
                        Spacer()
                        
                        Button("Retry") {
                            viewModel.refresh()
                        }
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.primary)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.warning.opacity(0.1))
                }
                
                // Search Bar
                searchBar
                
                // Content
                if viewModel.isLoading{
                    loadingView
                } else if viewModel.characters.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    characterList
                }
            }
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.refresh()
            }
        }
        
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search characters...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button("Clear") {
                    viewModel.searchText = ""
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md - 4)
        .background(AppColors.secondaryBackground)
        .appCornerRadius(AppCornerRadius.medium)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }
    
    private var loadingView: some View {
        LoadingView("Loading characters...")
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: viewModel.isOffline ? "wifi.slash" : "person.3.fill",
            title: viewModel.isSearching ? "No characters found" : (viewModel.isOffline ? "No cached characters" : "No characters available"),
            message: viewModel.isSearching ? "Try adjusting your search terms" : (viewModel.isOffline ? "Connect to internet to load characters" : "Pull to refresh to try again"),
            actionTitle: viewModel.isSearching ? nil : (viewModel.isOffline ? nil : "Retry"),
            action: viewModel.isSearching ? nil : (viewModel.isOffline ? nil : { viewModel.refresh() })
        )
    }
    
    private var characterList: some View {
        List {
            ForEach(viewModel.characters) { character in
                NavigationLink(destination: CharacterDetailsView(character: character)) {
                    CharacterRowView(character: character)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: AppSpacing.xs, leading: AppSpacing.md, bottom: AppSpacing.xs, trailing: AppSpacing.md))
            }
            
            // Load more indicator
            if viewModel.hasMorePages && !viewModel.isSearching {
                HStack {
                    Spacer()
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if viewModel.isOffline {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "wifi.slash")
                                                        .foregroundColor(AppColors.warning)
                        Text("Offline - Cannot load more")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.warning)
                        }
                    } else {
                        Button("Load More") {
                            viewModel.loadMoreCharacters()
                        }
                        .foregroundColor(AppColors.primary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            // Only auto-load more if we're not in initial load and user has scrolled
            // This prevents auto-loading page 2 when the view first appears
        }
    }
}

#Preview {
    CharacterListView()
}
