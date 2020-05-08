//
//  URL+Networking.swift
//  OnlineNavigation
//
//  Created by 瞿飞 on 2019/9/30.
//  Copyright © 2019 Mapbar Inc. All rights reserved.
//

import Foundation

public extension URL {
    init<T: TargetType>(target: T) {
        if target.path.isEmpty {
            self = target.baseURL
        } else {
            self = target.baseURL.appendingPathComponent(target.path)
        }
    }
}
