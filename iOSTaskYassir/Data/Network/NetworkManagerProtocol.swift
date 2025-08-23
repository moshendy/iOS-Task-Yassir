import Foundation
import Combine
import Alamofire

// MARK: - Network Manager Protocol
protocol NetworkManagerProtocol: ObservableObject {
    var isConnected: Bool { get }
    
    func request<T: Codable>(_ url: String, method: Alamofire.HTTPMethod, parameters: Alamofire.Parameters?) -> AnyPublisher<T, AppError>
    func startMonitoring()
    func stopMonitoring()
}
