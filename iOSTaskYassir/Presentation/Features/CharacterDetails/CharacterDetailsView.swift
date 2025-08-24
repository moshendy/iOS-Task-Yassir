//
//  CharacterDetailsView.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 23/08/2025.
//


import SwiftUI
import Kingfisher

struct CharacterDetailsView: View {
    let character: Character
    @StateObject private var viewModel: CharacterDetailsViewModel
    
    init(character: Character) {
        self.character = character
        self._viewModel = StateObject(wrappedValue: ServiceLocator.shared.createCharacterDetailsViewModel(character: character))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Header with image and basic info
                headerSection
                
                // Character details
                detailsSection
                
                // Origin and location
                locationSection
                
                // Episodes count
                episodesSection
            }
            .padding(AppSpacing.md)
        }
        .navigationTitle(character.name.value)
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Character Image
            KFImage(URL(string: character.image.url))
                .placeholder {
                    Rectangle()
                        .fill(AppColors.secondary.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(AppColors.secondary)
                                .font(.system(size: 60))
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: CharacterImageSize.defaultImageSize.width, height: CharacterImageSize.defaultImageSize.height)
                .appCornerRadius(AppCornerRadius.large)
                .appShadow(AppShadows.large)
            
            // Name and Status
            VStack(spacing: AppSpacing.sm) {
                Text(character.name.value)
                    .font(AppTypography.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: AppSpacing.md - 4) {
                    // Status indicator
                    HStack(spacing: AppSpacing.xs + 2) {
                        Circle()
                            .fill(character.statusColor)
                            .frame(width: AppSpacing.md - 4, height: AppSpacing.md - 4)
                        Text(character.status.value)
                            .font(AppTypography.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Text("•")
                        .foregroundColor(AppColors.secondary)
                    
                    Text(character.species.value)
                        .font(AppTypography.headline)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Details")
                .font(AppTypography.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: AppSpacing.md - 4) {
                detailRow(title: "Type", value: character.type.displayValue)
                detailRow(title: "Gender", value: character.gender.value)
                detailRow(title: "Created", value: character.created.formatted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Location")
                .font(AppTypography.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: AppSpacing.md - 4) {
                detailRow(title: "Origin", value: character.origin.name)
                detailRow(title: "Current Location", value: character.location.name)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Episodes")
                .font(AppTypography.title2)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: "tv.fill")
                    .foregroundColor(AppColors.primary)
                Text("\(character.episodes.count) episodes")
                    .font(AppTypography.headline)
                Spacer()
            }
            .padding(AppSpacing.md)
            .background(AppColors.primary.opacity(0.1))
            .appCornerRadius(AppCornerRadius.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.secondary)
                .frame(width: AppSpacing.md * 6.25, alignment: .leading)
            
            Text(value)
                .font(AppTypography.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
            
            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
    }
    
}

#Preview {
    let sampleCharacter = Character(
        id: CharacterID(1),
        name: CharacterName("Rick Sanchez"),
        status: CharacterStatus("Alive"),
        species: CharacterSpecies("Human"),
        type: CharacterType(""),
        gender: CharacterGender("Male"),
        origin: CharacterLocation(name: "Earth (C-137)", url: ""),
        location: CharacterLocation(name: "Earth (Replacement Dimension)", url: ""),
        image: CharacterImage("https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
        episodes: [
            EpisodeID("https://rickandmortyapi.com/api/episode/1"),
            EpisodeID("https://rickandmortyapi.com/api/episode/2")
        ],
        url: CharacterURL(""),
        created: CharacterCreatedDate(from: "2017-11-04T18:48:46.250Z")
    )
    
    return NavigationView {
        CharacterDetailsView(character: sampleCharacter)
    }
}
