//
//  KenImageView.swift
//  Touch Ken
//
//  Created by Paul on 3/30/15.
//  Copyright (c) 2015 Paul. All rights reserved.
//

import UIKit

@objc
protocol KenImageViewDelegate {
    optional func kenDidFinishedMoving(ken: KenImageView)
}
/// 這是一個會動有動畫的ImageView
class KenImageView: UIImageView {
    /// 成為delegate以得到Ken移動動畫結束通知
    weak var delegate: KenImageViewDelegate?
    private weak var mPinchGestureRecognizer:UIPinchGestureRecognizer!
    /**
    designed initializer
    
    :param: center KenImageView的center
    
    :returns: 帥氣的Ken
    */
    init(center: CGPoint) {
        super.init(
            frame: CGRect(
                origin: CGPointZero,
                size: CGSize(width: 58, height: 107)
            ))
        self.center = center
        setup()
    }
    /// 拉到storyboard會爆炸喔
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentMode = .ScaleAspectFit
        animationImages = map(1...6) {UIImage(named: "ken\($0)")!}
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:"))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "onPinch:")
        pinchGesture.delegate = self
        mPinchGestureRecognizer = pinchGesture
        
        addGestureRecognizer(pinchGesture)
        startAnimating()
        userInteractionEnabled = true
    }
    
    // MARK: - Gestures
    // MARK: UIPinchGestureRecognizer handler
    func onPinch(gesture: UIPinchGestureRecognizer) {
        if frame.size.width < 58 {
            self.removeFromSuperview()
        }
        let scale = gesture.scale
        bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformMakeScale(scale, scale))
        gesture.scale = 1
    }
    
    private var ken被放大了 = false
    private func ken放大縮小魔術() {
        let 倍率: CGFloat = 1.5
        if ken被放大了 { bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformMakeScale(1/倍率, 1/倍率)) }
            else      { bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformMakeScale(倍率, 倍率)) }
        ken被放大了 = !ken被放大了
    }
    // MARK: UIPanGestureRecognizer handler
    func onPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            superview?.bringSubviewToFront(self)
            // 放大 pinch手勢作用中則無作用
            if mPinchGestureRecognizer.state == .Possible { ken放大縮小魔術() }
            
            gesture.setTranslation(center, inView: self)
            fallthrough
        case .Changed:
            let newCenter = gesture.translationInView(self)
            center = gesture.translationInView(self)
        case .Ended:
            if ken被放大了 { ken放大縮小魔術() }
        default: break
        }
    }
    
    // MARK: - Move
    /**
    Ken向右移動`distance`個point，`distance`預設 = 50
    
    :param: distance ex:`10`是`向右`移動10
    */
    func goRight(_ distance: CGFloat = 50) {
        go(dx: distance, dy: 0)
    }
    /**
    Ken向左移動`distance`個point，`distance`預設 = 50
    
    :param: distance ex:`10`是向`左`移動10
    */
    func goLeft(_ distance: CGFloat = 50) {
        go(dx: -distance, dy: 0)
    }
    /// 慢慢來，等跑完動畫才進行下一次動畫...
    private var kenIsMoving = false
    func go(#dx:CGFloat, dy:CGFloat, _ duration:NSTimeInterval = 0.5) {
        // 慢慢來，等跑完動畫才進行下一次動畫...
        if kenIsMoving {return}
        kenIsMoving = true
        // ken從右邊出去左邊回來，左邊出去右邊回來，cool!
        if !CGRectIntersectsRect(superview!.frame, frame) {
            let newX = frame.origin.x + frame.size.width < 0 ? superview!.frame.width : 0 - frame.size.width
            frame = CGRect(origin: CGPoint(x: newX, y: frame.origin.y), size:frame.size)
        }
        // 動畫
        UIView.animateWithDuration(duration, delay: 0, options: .CurveLinear,
            animations: {
                self.frame = CGRectApplyAffineTransform(self.frame, CGAffineTransformMakeTranslation(dx, dy))
            },
            completion: { completed in
                self.delegate?.kenDidFinishedMoving?(self)
                self.kenIsMoving = false
        })
    }

}
// MARK: - UIGestureRecognizerDelegate
extension KenImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // FIXME: 這邊應該要多一點判斷...?
        return true
    }

}
