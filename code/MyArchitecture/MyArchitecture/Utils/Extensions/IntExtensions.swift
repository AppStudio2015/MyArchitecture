//
//  IntExtensions.swift
// MyArchitecture
//
//  Created by piaomiaozhiyuan on 2020/4/2.
//  Copyright © 2020 AppStudio. All rights reserved.
//

import Foundation

extension Int {
    
    func minute() -> Int {
        return Int(ceil(Double(self) / 60.0))
    }
    
    func km() -> Int {
        return Int(ceil(Double(self) / 1000.0))
    }
}
