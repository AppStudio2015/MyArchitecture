//
//  Cancellable.swift
//  OnlineNavigation
//
//  Created by 瞿飞 on 2019/9/29.
//  Copyright © 2019 Mapbar Inc. All rights reserved.
//

import Foundation

public protocol Cancellable {
    var isCancelled: Bool {get}
    func cancel()
}

internal class CancellableWrapper: Cancellable {
    internal var innerCancellable: Cancellable = SimpleCancellable()
    var isCancelled: Bool {
        return innerCancellable.isCancelled
    }
    internal func cancel() {
        self.innerCancellable.cancel()
    }
}

internal class SimpleCancellable: Cancellable {
    var isCancelled: Bool = false
    func cancel() {
        self.isCancelled = true
    }
}
