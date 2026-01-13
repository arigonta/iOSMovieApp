//
//  NetworkError.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Network Error Types
//

import Foundation

/// Errors that can occur during network operations
enum NetworkError: Error, Equatable {
    case invalidURL
    case noInternet
    case serverError(statusCode: Int)
    case decodingError(String)
    case unknown(String)
    
    /// User-friendly error message
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .noInternet:
            return "No internet connection. Please check your network settings."
        case .serverError(let statusCode):
            return "Server error (code: \(statusCode)). Please try again later."
        case .decodingError(let detail):
            return "Failed to process response: \(detail)"
        case .unknown(let detail):
            return "An unexpected error occurred: \(detail)"
        }
    }
    
    /// Whether the error is due to network connectivity
    var isNetworkError: Bool {
        switch self {
        case .noInternet:
            return true
        default:
            return false
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noInternet, .noInternet):
            return true
        case (.serverError(let lCode), .serverError(let rCode)):
            return lCode == rCode
        case (.decodingError(let lMsg), .decodingError(let rMsg)):
            return lMsg == rMsg
        case (.unknown(let lMsg), .unknown(let rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}

// MARK: - URLError Mapping
extension NetworkError {
    /// Creates a NetworkError from a URLError
    static func from(_ urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .dataNotAllowed,
             .internationalRoamingOff:
            return .noInternet
        case .badURL:
            return .invalidURL
        default:
            return .unknown(urlError.localizedDescription)
        }
    }
}
