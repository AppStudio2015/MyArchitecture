//
//  Response.swift
//  OnlineNavigation
//
//  Created by 瞿飞 on 2019/9/29.
//  Copyright © 2019 Mapbar Inc. All rights reserved.
//

import Foundation

public final class Response: Equatable {
    public let statusCode: Int
    public let data: Data
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    
    public init(statusCode: Int, data: Data, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
        self.statusCode = statusCode;
        self.data = data
        self.request = request
        self.response = response
    }
    
    public static func == (lhs: Response, rhs: Response) -> Bool {
        return lhs.statusCode == rhs.statusCode && lhs.data == rhs.data && lhs.response == lhs.response
    }
}
