//
//  SheetContainerView.swift
// MyArchitecture
//
//  Created by admin on 2020/3/27.
//  Copyright © 2020 AppStudio. All rights reserved.
//

import UIKit

protocol SheetContainerProtocol: NSObjectProtocol {
    func show() -> Void
    func dissmiss() -> Void
}

typealias SheetContainerDidShow = () -> Void
typealias SheetContainerDidDismiss = () -> Void

class SheetContainerView: UIView {
    public var topMargin: CGFloat = 0
    public var didShow: SheetContainerDidShow?
    public var didDismiss: SheetContainerDidDismiss?
    
    fileprivate(set) weak var subView: UIView?
    
    fileprivate var title: String? {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text
        }
    }
    
    fileprivate lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel.init(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        
        return label
    }()
    
    fileprivate lazy var closeButton: UIButton = {
        let button: UIButton!
        if #available(iOS 13.0, *) {
            button = UIButton.init(type: .close)
        } else {
            button = UIButton.init(type: .custom)
            button.setImage(UIImage(named: "closeDark"), for: .normal)
        }
        button.addTarget(self, action: #selector(self.handleCloseButton(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, title: String, subView: UIView?, hideButton: Bool = false) {
        self.init(frame:frame)
        self.subView = subView
        self.title = title
        if let aSubView = subView {
            addSubview(aSubView)
        }
        
        if !hideButton {
            self.addSubview(self.closeButton)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let titleLabelX: CGFloat = 8
        let titleLableY: CGFloat = 4
        let titleLableW: CGFloat = 200
        let titleLableH: CGFloat = 32
        self.titleLabel.frame = CGRect(x: titleLabelX, y: titleLableY, width: titleLableW, height: titleLableH)
        let closeBtnW: CGFloat = 32
        let closeBtnH: CGFloat = 32
        let closeBtnX: CGFloat = self.frame.width - 8 - closeBtnW
        let closeBtnY: CGFloat = titleLableY
        self.closeButton.frame = CGRect(x: closeBtnX, y: closeBtnY, width: closeBtnW, height: closeBtnH)
        self.subView?.frame = CGRect(x: 0, y: self.titleLabel.frame.maxY + 4, width: self.frame.width, height: self.frame.height)
    }
}

extension SheetContainerView {
    @objc fileprivate func handleCloseButton(_ button: UIButton) -> Void {
        self.dissmiss()
    }
}

extension SheetContainerView: SheetContainerProtocol {
    func show() {
//        let offsetY: CGFloat = self.bounds.height
        UIView.animate(withDuration: 0.4, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: self.topMargin, width: self.frame.width, height: self.frame.height)
        }) { [unowned self](finished) in
            self.didShow?()
        }
    }
    
    func dissmiss() {
//        let offsetY: CGFloat = self.bounds.height
        UIView.animate(withDuration: 0.4, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: UIScreen.main.bounds.height, width: self.frame.width, height: self.frame.height)
        }) { (finished) in
            self.didDismiss?()
        }
    }
}
