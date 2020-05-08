//
//  Provider.swift
//  OnlineNavigation
//
//  Created by 瞿飞 on 2019/9/29.
//  Copyright © 2019 Mapbar Inc. All rights reserved.
//

import Foundation

public typealias Completion = (_ result: Result<Response, NetworkingError>) -> Void

public protocol ProviderType: AnyObject {
    
    associatedtype Target: TargetType
    
    func request(with target: Target, callbackQueue: DispatchQueue?, comletion: @escaping Completion) -> Cancellable
}

open class Provider<Target: TargetType>: ProviderType {
    
    public typealias EndpointClosure = (Target) -> Endpoint
    public typealias RequestResultClosure = (Result<URLRequest, Error>) -> Void
    
    public let callbackQueue: DispatchQueue?
    public let sessionManager: URLSession
    public let endpointClosure: EndpointClosure
    public let trackInflights: Bool
    
    open internal(set) var inflightRequests: [Endpoint: Completion] = [:]
    
    public init(endpointClosure: @escaping EndpointClosure = Provider.defaultEndpointMapping,
                callbackQueue: DispatchQueue? = .none,
                manager: URLSession = Provider<Target>.defaultURLSessionManager(),
                trackInflights: Bool = false) {
        
        self.endpointClosure = endpointClosure
        self.callbackQueue = callbackQueue
        self.sessionManager = manager
        self.trackInflights = trackInflights
    }
    
    open func endpoint(with target: Target) -> Endpoint {
        return endpointClosure(target)
    }
    
    @discardableResult
    public func request<T: Codable>(with target: Target, responseModel: T.Type, completion: ((_ responseData: T?) -> Void)?) -> Cancellable? {
        
        guard let aCompletion = completion else { return nil }
        
        return self.request(with: target, callbackQueue: .none, comletion: { (result) in
            do {
                let response: Response = try result.get()
                let data = response.data
                let statusCode = response.statusCode
                let httpResponse = response.response
                
                #if DEBUG
                let string = String(data: data, encoding: String.Encoding.utf8)
                NSLog("Response Data = \(string ?? "Debug")")
                NSLog("Response Code = \(statusCode)")
                NSLog("Response Response = \(String(describing: httpResponse))")
                #endif
                
                if let modelData = JSONDecoder.decode(responseModel, from: data) {
                    aCompletion(modelData)
                } else {
                    aCompletion(nil)
                }
            } catch {
                let anError = error as CustomStringConvertible
                NSLog("Error=\(anError)")
                aCompletion(nil)
            }
        })
    }
    
    @discardableResult
    public func request(with target: Target, isNeedCallBackMainQueue: Bool = true, completion: ((_ responseData: NSDictionary?) -> Void)?) -> Cancellable? {
        
        guard let aCompletion = completion else { return nil }
        
        return self.request(with: target, callbackQueue: .none, comletion: { (result) in
            
            switch result {
            case .success(let response):
                let data = response.data
                let statusCode = response.statusCode
                let httpResponse = response.response
                
                #if DEBUG
                let string = String(data: data, encoding: String.Encoding.utf8)
                NSLog("Response Data = \(string ?? "Debug")")
                NSLog("Response Code = \(statusCode)")
                NSLog("Response Response = \(String(describing: httpResponse))")
                #endif
                
                let dic = JSONSerialization.myJsonObject(with: data)
                if isNeedCallBackMainQueue {
                    DispatchQueue.main.async {
                        aCompletion(dic)
                    }
                } else {
                    aCompletion(dic)
                }
                
            case .failure(let error):
                NSLog("Error=\(error)")
                if isNeedCallBackMainQueue {
                    DispatchQueue.main.async {
                        aCompletion(nil)
                    }
                } else {
                    aCompletion(nil)
                }
            }
        })
    }
    
    @discardableResult
    public func request(with target: Target, callbackQueue: DispatchQueue?, comletion: @escaping Completion) -> Cancellable {
        let aCallbackQueue = callbackQueue ?? self.callbackQueue
        return self.requestNormal(with: target, callbackQueue: aCallbackQueue, completion: comletion)
    }
}

extension Provider {
    
    @discardableResult
    fileprivate func requestNormal(with target: Target, callbackQueue: DispatchQueue?, completion: @escaping Completion) -> Cancellable {
        let endpoint = self.endpoint(with: target)
        let cancellableToken = CancellableWrapper()
        
        do {
            let requst = try endpoint.urlRequest()
            let dataTask = self.sessionManager.dataTask(with: requst) { (data, response, error) in
                
                let result = convertResponseToResult(response as? HTTPURLResponse, request: requst, data: data, error: error)
                completion(result)
                
            }
            dataTask.resume()
            
        } catch {
            let anError = NetworkingError.underlying(error, nil)
             completion(.failure(anError))
        }
        return cancellableToken
    }
    
    func cancelCompletion(_ completion: Completion?, target: Target) -> Void {
        let error = NetworkingError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil), nil)
        // Plugin
        
        completion?(.failure(error))
    }
}

extension Provider {
    
//    @discardableResult
//    func sendReuest(with target: Target, callbackQueue: DispatchQueue?, completion: @escaping Completion) -> Cancellable {
//
//    }
}

// MARK: - Defalut

public extension Provider {
    
    final class func defaultEndpointMapping(for target: Target) -> Endpoint {
        return Endpoint(url: URL(target:target).absoluteString,
                        method: target.method,
                        task: target.task,
                        httpHeaderFields: target.headers)
    }
    
    final class func defaultURLSessionManager() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }
    
    final class func defaultRequestMapping(for endpoint: Endpoint, closure: RequestResultClosure) -> Void {
        do {
            let urlRequest = try endpoint.urlRequest()
            closure(.success(urlRequest))
        } catch NetworkingError.requestMapping(let url) {
            closure(.failure(NetworkingError.requestMapping(url)))
        } catch NetworkingError.parameterEncoding(let error) {
            closure(.failure(NetworkingError.parameterEncoding(error)))
        } catch {
            closure(.failure(NetworkingError.underlying(error, nil)))
        }
    }
}

public func convertResponseToResult(_ response: HTTPURLResponse?, request: URLRequest?, data: Data?, error: Swift.Error?) -> Result<Response, NetworkingError> {
    switch (response, data, error) {
    case let (.some(response), data, .none):
        let response = Response(statusCode: response.statusCode, data: (data ?? Data()), request: request, response: response)
        return .success(response)
        
    case let (.some(response), _, .some(error)):
        let response = Response(statusCode: response.statusCode, data: (data ?? Data()), request: request, response: response)
        let error = NetworkingError.underlying(error, response)
        return .failure(error)
    case let (_, _, .some(error)):
        let error = NetworkingError.underlying(error, nil)
        return .failure(error)
    default:
        let error = NetworkingError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil), nil)
        return .failure(error)
    }
}
