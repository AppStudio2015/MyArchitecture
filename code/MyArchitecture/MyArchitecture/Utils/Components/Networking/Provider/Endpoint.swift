//
//  Endpoint.swift
//  OnlineNavigation
//
//  Created by 瞿飞 on 2019/9/29.
//  Copyright © 2019 Mapbar Inc. All rights reserved.
//

import Foundation

open class Endpoint {
    public let url: String
    public let method: Method
    public let task: Task
    public let httpHeaderFields: [String: String]?
    
    public init(url: String, method: Method, task: Task, httpHeaderFields: [String: String]?) {
        self.url = url;
        self.method = method
        self.task = task
        self.httpHeaderFields = httpHeaderFields
    }
}

extension Endpoint {
    
    public func urlRequest() throws -> URLRequest {
        guard let requestURL = Foundation.URL(string: url) else {
            throw NetworkingError.requestMapping(url)
        }
        
        var request: URLRequest = URLRequest(url: requestURL)
        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.httpHeaderFields
        
        switch self.task {
        case .requestPlain:
            return request
        case .requestData(let data):
            request.httpBody = data
            return request
        case .requestParameters(let parameters):
            guard let url = request.url else {
                return request
            }
            
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let paramString = NetworkingUtils.buildRequestParameters(with: parameters) {
                let urlParams = paramString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                let percentEncodeQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + (urlParams ?? "")
                urlComponents.percentEncodedQuery = percentEncodeQuery
                request.url = urlComponents.url
            }
            return request
            
        case .requestJSONEncodable(_):
            return request
            
        case .requestCustomJSONEncodable(_, _):
            return request
            
        case .requestCompositeData(let bodyData, let parameters):
            request.httpBody = bodyData
            guard let url = request.url else {
                return request
            }
            
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let paramString = NetworkingUtils.buildRequestParameters(with: parameters) {
                let urlParams = paramString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                let percentEncodeQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + (urlParams ?? "")
                urlComponents.percentEncodedQuery = percentEncodeQuery
                request.url = urlComponents.url
            }
            return request
            
        case .uploadFile(_):
            return request
            
//        @unknown default:
//            return request
        }
    }
}

extension Endpoint: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        guard let request = try? urlRequest() else {
            hasher.combine(url)
            return
        }
        hasher.combine(request)
    }
    
    public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
        let lhsRequest = try? lhs.urlRequest()
        let rhsRequest = try? rhs.urlRequest()
        
        if lhsRequest != nil, rhsRequest == nil {
            return false
        }
        
        if lhsRequest == nil, rhsRequest != nil {
            return false
        }
        
        if lhsRequest == nil, rhsRequest == nil {
            return lhs.hashValue == rhs.hashValue
        }
        
        return lhsRequest == rhsRequest
    }
}
