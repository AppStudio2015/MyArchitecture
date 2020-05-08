//
//  NetworkingError.swift
//  OnlineNavigation
//
//  Created by 瞿飞 on 2019/9/29.
//  Copyright © 2019 Mapbar Inc. All rights reserved.
//

import Foundation

public enum NetworkingError: Swift.Error {
    case jsonMapping(Response)
    case stringMapping(Response)
    case objectMapping(Swift.Error, Response)
    case encodableMapping(Swift.Error)
    case statusCode(Response)
    case underlying(Swift.Error, Response?)
    case requestMapping(String)
    case parameterEncoding(Swift.Error)
}

public extension NetworkingError {
    var response: Response? {
        switch self {
        case .jsonMapping(let response):
            return response
        case .stringMapping(let response):
            return response
        case .objectMapping(_, let response):
            return response
        case .encodableMapping:
            return nil
        case .statusCode(let response):
            return response
        case .underlying(_, let response):
            return response;
        case .requestMapping:
            return nil
        case .parameterEncoding:
            return nil
        }
    }
    
    internal var underlyingError: Swift.Error? {
        switch self {
        case .jsonMapping:
            return nil
        case .stringMapping:
            return nil
        case .objectMapping(let error, _):
            return error
        case .encodableMapping(let error):
            return error
        case .statusCode:
            return nil
        case .underlying(let error, _):
            return error
        case .requestMapping:
            return nil
        case .parameterEncoding(let error):
            return error
        }
    }
}

extension NetworkingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .jsonMapping:
            return "Failed to map data to JSON."
        case .stringMapping:
            return "Failed to map data to a Sring."
        case .objectMapping:
            return "Failed to map data to a Decodable object."
        case .encodableMapping:
            return "Failed to encode Encodable object into data."
        case .statusCode:
            return "Status code did'n fall within the given range."
        case .underlying(let error, _):
            return error.localizedDescription
        case .requestMapping:
            return "Failed to map Endpoint to URLRequest."
        case .parameterEncoding(let error):
            return "Failed to encode parameters for URLRequest. \(error.localizedDescription)"
        }
    }
}

extension NetworkingError: CustomNSError {
    public var errorUserInfo: [String : Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }
}
