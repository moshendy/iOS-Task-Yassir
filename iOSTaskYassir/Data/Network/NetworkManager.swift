import Foundation
import Alamofire
import Network
import Combine

// MARK: - Network Manager
class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    
    @Published var isConnected = true
    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        $isConnected.eraseToAnyPublisher()
    }
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startMonitoring()
    }
    
    private convenience init(shared: Bool) {
        self.init()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    func request<T: Codable>(_ url: String, method: HTTPMethod = .get, parameters: Parameters? = nil) -> AnyPublisher<T, AppError> {
        return Future<T, AppError> { promise in
            AF.request(url, method: method, parameters: parameters)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        promise(.success(value))
                    case .failure(let error):
                        let appError = self.mapAlamofireError(error)
                        promise(.failure(appError))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    private func mapAlamofireError(_ error: AFError) -> AppError {
        switch error {
        case .sessionTaskFailed(let underlyingError):
            if let urlError = underlyingError as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return .networkError("No internet connection")
                case .timedOut:
                    return .networkError("Request timed out")
                default:
                    return .networkError("Network error: \(urlError.localizedDescription)")
                }
            }
            return .networkError("Network error: \(underlyingError.localizedDescription)")
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                return .networkError("Server error: HTTP \(code)")
            default:
                return .networkError("Response validation failed")
            }
        case .responseSerializationFailed:
            return .decodingError("Failed to parse server response")
        default:
            return .networkError("Network error: \(error.localizedDescription)")
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    deinit {
        stopMonitoring()
    }
}
