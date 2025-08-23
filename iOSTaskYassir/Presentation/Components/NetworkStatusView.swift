import SwiftUI

struct NetworkStatusView: View {
    let isConnected: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: isConnected ? "wifi" : "wifi.slash")
                .foregroundColor(isConnected ? AppColors.success : AppColors.error)
                .font(AppTypography.caption)
            
            Text(isConnected ? "Connected" : "No Internet")
                .font(AppTypography.caption)
                .foregroundColor(isConnected ? AppColors.success : AppColors.error)
        }
        .padding(.horizontal, AppSpacing.md - 4)
        .padding(.vertical, AppSpacing.xs + 2)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(isConnected ? AppColors.success.opacity(0.1) : AppColors.error.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .stroke(isConnected ? AppColors.success.opacity(0.3) : AppColors.error.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        NetworkStatusView(isConnected: true)
        NetworkStatusView(isConnected: false)
    }
    .padding()
}
