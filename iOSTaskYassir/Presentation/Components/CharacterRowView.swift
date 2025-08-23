//
//  CharacterRowView.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 23/08/2025.
//


import SwiftUI
import Kingfisher

struct CharacterRowView: View {
    let character: Character
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Character Image
            KFImage(URL(string: character.image.url))
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: AppConfiguration.UI.imageCornerRadius))
            
            // Character Info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(character.name.value)
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(character.species.value)
                    .font(AppTypography.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: AppSpacing.xs) {
                    // Status indicator
                    Circle()
                        .fill(statusColor)
                        .frame(width: AppSpacing.sm, height: AppSpacing.sm)
                    
                    Text(character.status.value)
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()

        }
        .padding(.vertical, AppConfiguration.UI.listRowSpacing)
        .contentShape(Rectangle())
    }
    
    private var statusColor: Color {
        if character.status.isAlive {
            return AppColors.statusAlive
        } else if character.status.isDead {
            return AppColors.statusDead
        } else {
            return AppColors.statusUnknown
        }
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
        origin: CharacterLocation(name: "Earth", url: ""),
        location: CharacterLocation(name: "Earth", url: ""),
        image: CharacterImage("https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
        episodes: [],
        url: CharacterURL(""),
        created: CharacterCreatedDate(from: "2017-11-04T18:48:46.250Z")
    )
    
    return CharacterRowView(character: sampleCharacter)
        .padding()
}
