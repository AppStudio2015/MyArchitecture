//
//  ArrayExtensions.swift
// MyArchitecture
//
//  Created by piaomiaozhiyuan on 2020/4/1.
//  Copyright © 2020 AppStudio. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    /// Removes the first given object
    public mutating func removeFirst(_ element: Element) {
        guard let index = firstIndex(of: element) else { return }
        self.remove(at: index)
    }
}
