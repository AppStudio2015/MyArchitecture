//
//  BaseView.swift
// MyArchitecture
//
//  Created by QF on 2019/6/4.
//  Copyright © 2019 AppStudio. All rights reserved.
//

import UIKit

class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .unspecified
        } else {
            
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
