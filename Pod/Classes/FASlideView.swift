//
//  FASlideView.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 19/06/15.
//
//

import Foundation
import UIKit

@objc public protocol FASlideViewDelegate {
    func slideView(slideView: FASlideView, didTouchView: UIView, atIndex:Int)
}

@objc public protocol FASlideViewDataSource {
    func numberOfViews(slideView: FASlideView) -> Int
    func slideView(slideView: FASlideView, viewForViewAtIndex: Int) -> UIView
    func slideView(slideView: FASlideView, transitionFromView:UIView, toView: UIView, complete: () -> Void)
    func slideView(slideView: FASlideView, didTouchView: UIView, atIndex:Int)
    
}
public class FASlideView : UIView {
    public var delegate : FASlideViewDelegate?
    public var dataSource : FASlideViewDataSource?
    public var randomize : Bool = false
    
    public var defaultView : UIView? {
        didSet (view) {
            if self.currentView != nil {
                return
            }
            
            for subview in self.subviews {
                subview.removeFromSuperview()
            }
            
            if view != nil {
                self.addSubview(view!)
            }
            
        }
    }
  
    public required  init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)!
      self.commonInit()
    }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  func commonInit () {
    let gesture = UITapGestureRecognizer()
    self.addGestureRecognizer(gesture)
    gesture.addTarget(self, action: "onClick:")
  }
  
  func onClick(sender: UIView) {
    if self.currentView == nil {
      return
    } else if self.currentView! === self.defaultView {
      return
    }

    self.dataSource?.slideView(self, didTouchView: self.currentView!, atIndex: currentIndex - 1)
  }
  
    public var transition : UIViewAnimationTransition? = UIViewAnimationTransition.FlipFromLeft
    public var interval: NSTimeInterval = 10
    
    private var currentIndex : Int = 0
    private var currentView : UIView?
    private var timer : NSTimer?
    
    public func start () {
        self.stop()
        
        if self.dataSource == nil {
            return
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.interval, target: self, selector: "onTimerFired:", userInfo: nil, repeats: true)
        
        NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode:NSRunLoopCommonModes)
        self.onTimerFired(self.timer!)
    }
    
    public func stop () {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
        
    }
    
    
    func onTimerFired(time:NSTimer) {
        let count = self.dataSource!.numberOfViews(self)
    
        if count == 0 {
            self.useDefaultView()
            return
        }
        
        let next = self.nextIndex(count)
    
        let view = self.dataSource?.slideView(self, viewForViewAtIndex: next)
        
        if view != nil {
            self.setView(view!)
        } else {
            self.useDefaultView()
        }
        
    }
    
    private func useDefaultView () {
        if self.defaultView == nil || self.currentView === self.defaultView {
            return
        }
        
        self.setView(self.defaultView!)
    }
    
    private func setView (view: UIView) {
    
        func clear () {
            for view in self.subviews {
                view.removeFromSuperview()
            }
        }
        
        if self.currentView === view {
            return
        }
        
        view.frame = self.bounds
        
        if self.currentView != nil {
            clear()
            self.addSubview(view)
            self.currentView = view
        } else {

            self.addSubview(view)
            self.dataSource!.slideView(self, transitionFromView: self.currentView!, toView: view, complete: { () -> Void in
                self.currentView?.removeFromSuperview()
                self.currentView = view
            })
        }
        
        
        
    }
    
    private func nextIndex (count: Int) -> Int {
        let next : Int
        if self.randomize {
            var rnd = 0
            if count > 1 {
                rnd = Int(rand()) % (count - 1)
            }
            if rnd == currentIndex && count != 1 {
                rnd = nextIndex(count)
            }
            next = rnd
        } else {
            if currentIndex == count {
                currentIndex = 0
            }
            next = currentIndex++
        }
        
        return next
    }
  

    
    deinit {
        self.stop()
    }
    
    
}

