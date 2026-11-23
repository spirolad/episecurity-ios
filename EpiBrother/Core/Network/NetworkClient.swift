//
//  NetworkClient.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case forbidden(String)
    case notFound(String)
    case badRequest(String)
    case conflict(String)
    case serverError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL de requête invalide."
        case .unauthorized:
            return "Session expirée ou identifiants incorrects (401 Non autorisé)."
        case .forbidden(let msg):
            return "Accès interdit : \(msg)"
        case .notFound(let msg):
            return "Ressource introuvable : \(msg)"
        case .badRequest(let msg):
            return "Données invalides : \(msg)"
        case .conflict(let msg):
            return "Conflit : \(msg)"
        case .serverError(let code, let msg):
            return "Erreur serveur (\(code)) : \(msg)"
        case .decodingError(let err):
            return "Erreur de formatage des données : \(err.localizedDescription)"
        case .networkError(let err):
            return "Erreur réseau : \(err.localizedDescription)"
        case .unknown:
            return "Une erreur inattendue est survenue."
        }
    }
}

public protocol NetworkClientProtocol {
    func execute<T: Decodable>(endpoint: APIEndpoint, body: (any Encodable)?, token: String?) async throws -> T
    func executeWithoutResponse(endpoint: APIEndpoint, body: (any Encodable)?, token: String?) async throws
}

public class NetworkClient: NSObject, NetworkClientProtocol {
    public static let shared = NetworkClient()
    
    private var session: URLSession
    private let certificatePinning = CertificatePinning.shared
    
    public override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        super.init()
        self.session = URLSession(configuration: configuration, delegate: certificatePinning, delegateQueue: nil)
    }
    
    public static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            // Format 1: ISO8601 with fractional seconds
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            // Format 2: Standard ISO8601 LocalDateTime
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            // Format 3: ISO8601 with timezone Z / offset
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }
            
            // Fallback: Date timestamp
            if let timestamp = Double(dateStr) {
                return Date(timeIntervalSince1970: timestamp)
            }
            
            return Date()
        }
        return decoder
    }
    
    public static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }
    
    public func execute<T: Decodable>(endpoint: APIEndpoint, body: (any Encodable)? = nil, token: String? = nil) async throws -> T {
        let data = try await performRequest(endpoint: endpoint, body: body, token: token)
        do {
            return try NetworkClient.jsonDecoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            let responseString = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("Failed to decode response: \(responseString)")
            #endif
            throw APIError.decodingError(error)
        }
    }
    
    public func executeWithoutResponse(endpoint: APIEndpoint, body: (any Encodable)? = nil, token: String? = nil) async throws {
        _ = try await performRequest(endpoint: endpoint, body: body, token: token)
    }
    
    private func performRequest(endpoint: APIEndpoint, body: (any Encodable)?, token: String?) async throws -> Data {
        guard let url = endpoint.url() else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try NetworkClient.jsonEncoder.encode(body)
            } catch {
                throw APIError.badRequest("Impossible d'encoder le corps de la requête.")
            }
        }
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        let statusCode = httpResponse.statusCode
        if (200...299).contains(statusCode) {
            return data
        }
        
        // Extraction du message d'erreur éventuel retourné par Spring Boot
        let errorMessage = extractErrorMessage(from: data)
        
        switch statusCode {
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden(errorMessage ?? "Accès non autorisé pour ce profil.")
        case 404:
            throw APIError.notFound(errorMessage ?? "Entité introuvable.")
        case 409:
            throw APIError.conflict(errorMessage ?? "Conflit de ressource.")
        case 400:
            throw APIError.badRequest(errorMessage ?? "Requête invalide.")
        default:
            throw APIError.serverError(statusCode: statusCode, message: errorMessage ?? "Erreur HTTP \(statusCode)")
        }
    }
    
    private func extractErrorMessage(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = json["message"] as? String {
                return message
            }
            if let error = json["error"] as? String {
                return error
            }
        }
        return String(data: data, encoding: .utf8)
    }
}
