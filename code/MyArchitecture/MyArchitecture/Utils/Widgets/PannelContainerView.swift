//
//  PannelContainerView.swift
// MyArchitecture
//
//  Created by admin on 2020/3/25.
//  Copyright © 2020 AppStudio. All rights reserved.
//

import UIKit

// MARK: - PannelContainerSubViewProtocol
protocol PannelContainerSubViewProtocol {
    
    /// 隐藏指定视图
    /// - Parameters:
    ///   - view: 指定视图,为Nil时隐藏默认视图
    ///   - animated: 动画
    func hideSpecificView(_ view: UIView?, animated: Bool)
    
    /// 显示指定视图
    /// - Parameters:
    ///   - view: 指定视图,为Nil时显示默认视图
    ///   - animated: 动画
    func showSpecificView(_ view: UIView?, animated: Bool)
}

extension PannelContainerSubViewProtocol {
    func hideSpecificView(_ view: UIView?, animated: Bool) {
        
    }
    
    func showSpecificView(_ view: UIView?, animated: Bool) {
        
    }
}

// MARK: - PannelContainerView
enum PannelContainerViewLocation {
    case top(y: CGFloat)
    case middle(y: CGFloat)
    case bottom(y: CGFloat)
    case other(y: CGFloat)
}

protocol PannelContainerViewDelegate: NSObjectProtocol {
    func pannelContainerView(_ view: PannelContainerView, didMoveTo location: CGPoint)
    func pannelContainerView(_ view: PannelContainerView, didMoveToTop location: CGPoint)
    func pannelContainerView(_ view: PannelContainerView, didMoveToMiddle location: CGPoint)
    func pannelContainerView(_ view: PannelContainerView, didMoveToBottom location: CGPoint)
}

class PannelContainerView: BaseView {
    
    public weak var targetView: UIView?
    public weak var delegate: PannelContainerViewDelegate?
    
    fileprivate var subView: UIView?
    fileprivate var originY: CGFloat = 0
    fileprivate var locaionY: CGFloat = 0
    fileprivate var offsetY: CGFloat = 0
    fileprivate var subScrollView: UIScrollView?
    
    fileprivate let topY: CGFloat = UIDevice.current.isIPhoneXSeries() ? 44 : 20
    fileprivate let middleY: CGFloat = UIScreen.main.bounds.height / 2
    fileprivate let bottomY: CGFloat = UIScreen.main.bounds.height - 100
    
    fileprivate var pannelBar: UIView = {
        let view = UIView.init(frame: .zero)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    fileprivate lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar.init()
        if #available(iOS 13.0, *) {
//            searchBar.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        searchBar.searchBarStyle = .minimal
//        searchBar.backgroundColor = UIColor.clear
        searchBar.showsScopeBar = false
        searchBar.showsCancelButton = false
        searchBar.isTranslucent = true
//        searchBar.tintColor = UIColor.clear
        searchBar.placeholder = NSLocalizedString("searchBarPlacehoder", comment: "")
        searchBar.delegate = self
        return searchBar
    }()
    

    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(didPan(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    fileprivate lazy var swipeDownGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer.init(target: self, action: #selector(didSwipe(_:)))
        gesture.direction = .down
        gesture.delegate = self
        return gesture
    }()
    
    fileprivate lazy var swipeUpGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer.init(target: self, action: #selector(didSwipe(_:)))
        gesture.direction = .up
        gesture.delegate = self
        return gesture
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.addSubview(pannelBar)
        //self.addSubview(searchBar)
        
        self.addGestureRecognizer(self.panGesture)
//        self.addGestureRecognizer(self.swipeDownGesture)
//        self.addGestureRecognizer(self.swipeUpGesture)
//        self.swipeDownGesture.require(toFail: self.panGesture)
//        self.swipeUpGesture.require(toFail: self.panGesture)
        
        self.addNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let pannelBarW: CGFloat = 40
        let pannelBarH: CGFloat = 6
        let pannelBarX: CGFloat = (self.frame.width - pannelBarW) / 2
        let pannelBarY: CGFloat = 4
        self.pannelBar.frame = CGRect(x: pannelBarX, y: pannelBarY, width: pannelBarW, height: pannelBarH)
        self.searchBar.frame = CGRect(x: 12, y: self.pannelBar.frame.maxY + 4, width: self.frame.width - 24, height: 48)
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        self.subView = view
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        print("\(#function)")
        
        if self.isHidden || self.alpha < 0.01 || self.isUserInteractionEnabled == false {
            return nil
        }
        
        if self.point(inside: point, with: event) == false {
            return nil
        }
        
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        
        if view is UIScrollView {
            self.subScrollView = view as? UIScrollView
        } else if view.superview is UITableViewCell || view.superview is UICollectionViewCell {
            self.subScrollView = view.superview?.superview as? UIScrollView
        } else {
            self.subScrollView = nil
        }
        
        return view
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    // MARK: - Private Methods
    fileprivate func addNotifications() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(moveToTop(_:)), name: .PannelContainerMoveToTop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveToMiddle(_:)), name: .PannelContainerMoveToMiddle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveToBottom(_:)), name: .PannelContainerMoveToBottom, object: nil)
    }
}

extension PannelContainerView {
    
    @objc fileprivate func didPan(_ panGestureRecognizer: UIPanGestureRecognizer) -> Void {
        guard let aTargetView = self.targetView else {
            return
        }
        
        let point: CGPoint = panGestureRecognizer.translation(in: aTargetView)
        let velocityPoint: CGPoint = panGestureRecognizer.velocity(in: panGestureRecognizer.view)
        let locationPoint: CGPoint = panGestureRecognizer.location(in: aTargetView)
        print("point=\(point)")
        print("velocityPoint=\(velocityPoint)")
        print("locationPoint=\(locationPoint)")
        print("self.frame.origin.y=\(self.frame.origin.y)")
        
        switch panGestureRecognizer.state {
        case .began:
            self.originY = point.y
            self.offsetY = locationPoint.y - self.frame.origin.y
            print("beganY=\(point.y)")
        case .changed:
            print("changedY=\(locationPoint.y)")
            if self.frame.origin.y <= self.topY, velocityPoint.y <= 0 { // Top -> 向上滑动
                if let scrollView = self.subScrollView {
                    scrollView.isScrollEnabled = true
                }
                return
            }
            
            if self.frame.origin.y == self.topY, velocityPoint.y > 0 { // Top -> 向上滑动, 保证ScrollView先滑动
                if let scrollView = self.subScrollView {
                    if scrollView.contentOffset.y > 0 {
                        scrollView.isScrollEnabled = true
                        return
                    } else {
                        scrollView.isScrollEnabled = true
                    }
                }
            }
            
            if self.frame.origin.y >= self.bottomY, velocityPoint.y > 0 { // 向下滑动
                return
            }
            
            if self.frame.origin.y >= self.topY, velocityPoint.y > 0 { // 向下滑动
                if let scrollView = self.subScrollView {
                    if scrollView.contentOffset.y <= 0 {
                        scrollView.isScrollEnabled = false
                    } else {
                        scrollView.isScrollEnabled = true
                    }
                }
            }
            
            if self.frame.origin.y > self.topY, self.frame.origin.y < self.bottomY {
                if let scrollView = self.subScrollView {
                    scrollView.isScrollEnabled = false
                }
            }
            
//            if (locationPoint.y - self.offsetY) < self.topY {
//                return
//            }
            self.moveTo(location: locationPoint.y - self.offsetY, animated: true)
            panGestureRecognizer.setTranslation(CGPoint.zero, in: panGestureRecognizer.view)
        case .ended:
            print("endedY=\(point.y)")
            self.subScrollView?.isScrollEnabled = true
            if self.frame.origin.y <= self.topY, velocityPoint.y <= 0 { // Top -> 向上滑动
                self.moveTo(location: self.topY, animated: true)
            } else if self.frame.origin.y > self.middleY, self.frame.origin.y < self.bottomY, velocityPoint.y < 0  { // Middle -> Top 向上滑动
                self.moveTo(location: self.middleY, animated: true)
            } else if self.frame.origin.y > self.middleY, self.frame.origin.y < self.bottomY, velocityPoint.y > 0 { // Top -> Middle 向下滑动
                self.moveTo(location: self.bottomY, animated: true)
            } else if self.frame.origin.y > self.topY, self.frame.origin.y < self.middleY, velocityPoint.y < 0 { // Bottom -> Middle 向上滑动
                self.moveTo(location: self.topY, animated: true)
            } else if self.frame.origin.y > self.topY, self.frame.origin.y < self.middleY, velocityPoint.y > 0 { // Middle -> Bottom 向下滑动
                self.moveTo(location: self.middleY, animated: true)
            } else if self.frame.origin.y >= self.bottomY, velocityPoint.y >= 0 { // Bottom -> 向下滑动
                self.moveTo(location: self.bottomY, animated: true)
            } else {
//                self.subScrollView?.isScrollEnabled = true
            }
        default:
            break
        }

//        // 向上滑动
//        if velocityPoint.y < 0 {
//            print("向上滑动")
//        }
//
//        // 向下滑动
//        if velocityPoint.y > 0 {
//            print("向下滑动")
//        }
    }
    
    @objc fileprivate func didSwipe(_ swipeGesture: UISwipeGestureRecognizer) -> Void {
        guard let aTargetView = self.targetView else {
            return
        }
        
        let point: CGPoint = swipeGesture.location(in: aTargetView)
        print("point=\(point)")
        let location: CGPoint = swipeGesture.location(ofTouch: 1, in: self)
        print("locationPoint=\(location)")
        
        let direction = swipeGesture.direction
        let originY: CGFloat = self.frame.origin.y
        switch direction {
        case .down:
            if [self.topY,self.middleY].contains(originY) {
                self.endEditing(true)
                self.moveToMiddle()
                break
            }
            
            if [self.middleY,self.bottomY].contains(originY) {
                self.moveToBottom()
                break
            }
            break
        case .up:
            if [self.middleY, bottomY].contains(originY) {
                self.moveToMiddle()
                break
            }
            
            if [self.topY, self.middleY].contains(originY) {
                self.moveToTop()
                break
            }
            
        default:
            break
        }
    }
}

extension PannelContainerView {
    
    @objc public func moveToTop(_ animated: Bool = true) -> Void {
        
        self.moveTo(location: self.topY, animated: true)
    }
    
    @objc public func moveToMiddle(_ animated: Bool = true) -> Void {
        guard let aTargetView = self.targetView else {
            return
        }
        let location = aTargetView.frame.height / 2
        self.moveTo(location: location, animated: true)
    }
    
    @objc public func moveToBottom(_ animated: Bool = true) -> Void {
        guard let aTargetView = self.targetView else {
            return
        }
        let location = aTargetView.frame.height - 100
        self.moveTo(location: location, animated: true)
    }
    
    @objc public func moveTo(location: CGFloat, animated: Bool = true) -> Void {
        var aLocation = location
        if location < self.topY {
            aLocation = self.topY
        }
        if location > self.bottomY {
            aLocation = self.bottomY
        }
        
        let duration: TimeInterval = animated ? 0.15 : 0
        UIView.animate(withDuration: duration, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: aLocation, width: self.frame.width, height: self.frame.height)
        }) { (finished) in
            self.delegate?.pannelContainerView(self, didMoveTo: self.frame.origin)
        }
    }
    
//    fileprivate func move(to location: PannelContainerViewLocation, animated: Bool = true) -> Void {
//        switch location {
//        case .top(let y):
//            break
//        case .middle(y: let y):
//            break
//        case .bottom(y: let y):
//            break
//        case .other(y: let y):
//            break
//        default:
//            break
//        }
//    }
}

extension PannelContainerView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PannelContainerView: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.endEditing(true)
        searchBar.showsCancelButton = false
        let height: CGFloat = self.targetView?.frame.height ?? UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.4, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: height - 100, width: self.frame.width, height: self.frame.height)
        }) { (finished) in

        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        UIView.animate(withDuration: 0.4, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: 60, width: self.frame.width, height: self.frame.height)
        }) { (finished) in

        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.endEditing(true)
    }
}
