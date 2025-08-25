import SwiftUI

// MARK: - Colors
struct AppColors {
    static let primary = Color.blue
    static let secondary = Color.secondary
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Status colors
    static let statusAlive = Color.green
    static let statusDead = Color.red
    static let statusUnknown = Color.gray
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 24
}

// MARK: - Shadows
struct AppShadows {
    static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    static let medium = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    static let large = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Typography
struct AppTypography {
    static let largeTitle = Font.largeTitle
    static let title = Font.title
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
}

// MARK: - Timing
struct AppTiming {
    static let searchDebounceTime: TimeInterval = 0.5
    static let defaultAnimationDuration: Double = 0.3
}


// MARK: - Character
struct CharacterImageSize {
    static let defaultImageSize = CGSize(width: 200, height: 200)
    static let thumbnailImageSize = CGSize(width: 60, height: 60)
}

// MARK: - View Extensions
extension View {
    func appShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func appCornerRadius(_ radius: CGFloat) -> some View {
        self.cornerRadius(radius)
    }
}
