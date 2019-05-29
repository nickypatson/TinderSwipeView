//
//  EmojiRateView.swift
//  EmojiRate
//
//  Created by zorro on 15/10/17.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class EmojiRateView: UIView {
    /// Rate default color for rateValue = 5
    fileprivate static let rateLineColorBest: UIColor = .green
    
    /// Rate default color for rateValue = 0
    fileprivate static let rateLineColorWorst: UIColor = .red
    
    // MARK: -
    // MARK: Private property.
    
    fileprivate var shapeLayer: CAShapeLayer = CAShapeLayer.init()
    fileprivate var shapePath: UIBezierPath = UIBezierPath.init()
    
    fileprivate var rateFaceMargin: CGFloat = 1
    fileprivate var touchPoint: CGPoint? = nil
    fileprivate var hueFrom: CGFloat = 0, saturationFrom: CGFloat = 0, brightnessFrom: CGFloat = 0, alphaFrom: CGFloat = 0
    fileprivate var hueDelta: CGFloat = 0, saturationDelta: CGFloat = 0, brightnessDelta: CGFloat = 0, alphaDelta: CGFloat = 0
    
    // MARK: -
    // MARK: Public property.
    
    /// Line width.
    @IBInspectable open var rateLineWidth: CGFloat = 14 {
        didSet {
            if rateLineWidth > 20 {
                rateLineWidth = 20
            }
            if rateLineWidth < 0.5 {
                rateLineWidth = 0.5
            }
            self.rateFaceMargin = rateLineWidth / 2
            redraw()
        }
    }
    
    /// Current line color.
    @IBInspectable open var rateColor: UIColor = UIColor.init(red: 55 / 256, green: 46 / 256, blue: 229 / 256, alpha: 1.0) {
        didSet {
            redraw()
        }
    }
    
    /// Color range
    open var rateColorRange: (from: UIColor, to: UIColor) = (EmojiRateView.rateLineColorWorst, EmojiRateView.rateLineColorBest) {
        didSet {
            // Get begin color
            rateColorRange.from.getHue(&hueFrom, saturation: &saturationFrom, brightness: &brightnessFrom, alpha: &alphaFrom)
            
            // Get end color
            var hueTo: CGFloat = 1, saturationTo: CGFloat = 1, brightnessTo: CGFloat = 1, alphaTo: CGFloat = 1
            rateColorRange.to.getHue(&hueTo, saturation: &saturationTo, brightness: &brightnessTo, alpha: &alphaTo)
            
            // Update property
            hueDelta = hueTo - hueFrom
            saturationDelta = saturationTo - saturationFrom
            brightnessDelta = brightnessTo - brightnessFrom
            alphaDelta = alphaTo - alphaFrom
            
            // Force to refresh current color
            let currentRateValue = rateValue
            rateValue = currentRateValue
        }
    }
    
    /// If line color changes with rateValue.
    @IBInspectable open var rateDynamicColor: Bool = true {
        didSet {
            redraw()
        }
    }
    
    /// Mouth width. From 0.2 to 0.7.
    @IBInspectable open var rateMouthWidth: CGFloat = 0.6 {
        didSet {
            if rateMouthWidth > 0.7 {
                rateMouthWidth = 0.7
            }
            if rateMouthWidth < 0.2 {
                rateMouthWidth = 0.2
            }
            redraw()
        }
    }
    
    /// Mouth lip width. From 0.2 to 0.9
    @IBInspectable open var rateLipWidth: CGFloat = 0.7 {
        didSet {
            if rateLipWidth > 0.9 {
                rateLipWidth = 0.9
            }
            if rateLipWidth < 0.2 {
                rateLipWidth = 0.2
            }
            redraw()
        }
    }
    
    /// Mouth vertical position. From 0.1 to 0.5.
    @IBInspectable open var rateMouthVerticalPosition: CGFloat = 0.35 {
        didSet {
            if rateMouthVerticalPosition > 0.5 {
                rateMouthVerticalPosition = 0.5
            }
            if rateMouthVerticalPosition < 0.1 {
                rateMouthVerticalPosition = 0.1
            }
            redraw()
        }
    }
    
    /// If show eyes.
    @IBInspectable open var rateShowEyes: Bool = true {
        didSet {
            redraw()
        }
    }
    
    /// Eye width. From 0.1 to 0.3.
    @IBInspectable open var rateEyeWidth: CGFloat = 0.2 {
        didSet {
            if rateEyeWidth > 0.3 {
                rateEyeWidth = 0.3
            }
            if rateEyeWidth < 0.1 {
                rateEyeWidth = 0.1
            }
            redraw()
        }
    }
    
    /// Eye vertical position. From 0.6 to 0.8.
    @IBInspectable open var rateEyeVerticalPosition: CGFloat = 0.6 {
        didSet {
            if rateEyeVerticalPosition > 0.8 {
                rateEyeVerticalPosition = 0.8
            }
            if rateEyeVerticalPosition < 0.6 {
                rateEyeVerticalPosition = 0.6
            }
            redraw()
        }
    }
    
    /// Rate value. From 0 to 5.
    @IBInspectable open var rateValue: Float = 2.5 {
        didSet {
            if rateValue > 5 {
                rateValue = 5
            }
            if rateValue < 0 {
                rateValue = 0
            }
            
            // Update color
            if rateDynamicColor {
                let rate: CGFloat = CGFloat(rateValue / 5)
                
                // Calculate new color
                self.rateColor = UIColor.init(
                    hue: hueFrom + hueDelta * rate,
                    saturation: saturationFrom + saturationDelta * rate,
                    brightness: brightnessFrom + brightnessDelta * rate,
                    alpha: alphaFrom + alphaDelta * rate)
            }
            
            // Callback
            self.rateValueChangeCallback?(rateValue)
            
            redraw()
        }
    }
    
    /// If you are using this with a scroll view, for example, this allows the scroll view to recognize pan gestures at the same time.
    @IBInspectable open var recognizeSimultanousGestures: Bool = false
    
    /// Callback when rateValue changes.
    open var rateValueChangeCallback: ((_ newRateValue: Float) -> Void)? = nil
    
    /// Sensitivity when drag. From 1 to 10.
    open var rateDragSensitivity: CGFloat = 5 {
        didSet {
            if rateDragSensitivity > 10 {
                rateDragSensitivity = 10
            }
            if rateDragSensitivity < 1 {
                rateDragSensitivity = 1
            }
        }
    }
    
    // MARK: -
    // MARK: Public methods.
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    /**
     Override layoutSubviews
     */
    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    // MARK: -
    // MARK: Private methods.
    
    /**
    Init configure.
    */
    fileprivate func configure() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        addGestureRecognizer(panRecognizer)
        panRecognizer.delegate = self
        
        self.backgroundColor = self.backgroundColor ?? UIColor.white
        self.clearsContextBeforeDrawing = true
        self.isMultipleTouchEnabled = false
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        rateColorRange = (EmojiRateView.rateLineColorWorst, EmojiRateView.rateLineColorBest)

        self.layer.addSublayer(shapeLayer)
        redraw()
    }
    
    /**
     Redraw all lines.
     */
    fileprivate func redraw() {
        shapeLayer.frame = self.bounds
        shapeLayer.strokeColor = rateColor.cgColor;
        shapeLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        shapeLayer.lineWidth = rateLineWidth
        
        shapePath.removeAllPoints()
        shapePath.append(facePathWithRect(self.bounds))
        shapePath.append(mouthPathWithRect(self.bounds))
        shapePath.append(eyePathWithRect(self.bounds, isLeftEye: true))
        shapePath.append(eyePathWithRect(self.bounds, isLeftEye: false))
        
        shapeLayer.path = shapePath.cgPath
        self.setNeedsDisplay()
    }
    
    /**
     Generate face UIBezierPath
     
     - parameter rect: rect
     
     - returns: face UIBezierPath
     */
    fileprivate func facePathWithRect(_ rect: CGRect) -> UIBezierPath {
        let margin = rateFaceMargin + 2
        let facePath = UIBezierPath(ovalIn: rect.inset(by: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)))
        return facePath
    }
    
    /**
     Generate mouth UIBezierPath
     
     - parameter rect: rect
     
     - returns: mouth UIBezierPath
     */
    fileprivate func mouthPathWithRect(_ rect: CGRect) -> UIBezierPath {
        let width = rect.width
        let height = rect.width
        
        let leftPoint = CGPoint(
            x: width * (1 - rateMouthWidth) / 2,
            y: height * (1 - rateMouthVerticalPosition))
        
        let rightPoint = CGPoint(
            x: width - leftPoint.x,
            y: leftPoint.y)
        
        let centerPoint = CGPoint(
            x: width / 2,
            y: leftPoint.y + height * 0.3 * (CGFloat(rateValue) - 2.5) / 5)
        
        let halfLipWidth = width * rateMouthWidth * rateLipWidth / 2
        
        let mouthPath = UIBezierPath()
        mouthPath.move(to: leftPoint)
        
        mouthPath.addCurve(
            to: centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPoint(x: centerPoint.x - halfLipWidth, y: centerPoint.y))
        
        mouthPath.addCurve(
            to: rightPoint,
            controlPoint1: CGPoint(x: centerPoint.x + halfLipWidth, y: centerPoint.y),
            controlPoint2: rightPoint)
        
        return mouthPath
    }
    
    /**
     Generate eye UIBezierPath
     
     - parameter rect:      rect
     - parameter isLeftEye: is left eye
     
     - returns: eye UIBezierPath
     */
    fileprivate func eyePathWithRect(_ rect: CGRect, isLeftEye: Bool) -> UIBezierPath {
        if !rateShowEyes {
            return UIBezierPath.init()
        }
        
        let width = rect.width
        let height = rect.width
        
        let centerPoint = CGPoint(
            x: width * (isLeftEye ? 0.30 : 0.70),
            y: height * (1 - rateEyeVerticalPosition) - height * 0.1 * (CGFloat(rateValue > 2.5 ? rateValue : 2.5) - 2.5) / 5)
        
        let leftPoint = CGPoint(
            x: centerPoint.x - rateEyeWidth / 2 * width,
            y: height * (1 - rateEyeVerticalPosition))
        
        let rightPoint = CGPoint(
            x: centerPoint.x + rateEyeWidth / 2 * width,
            y: leftPoint.y)
        
        let eyePath = UIBezierPath()
        eyePath.move(to: leftPoint)
        
        eyePath.addCurve(
            to: centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPoint(x: centerPoint.x - width * 0.06, y: centerPoint.y))
        
        eyePath.addCurve(
            to: rightPoint,
            controlPoint1: CGPoint(x: centerPoint.x + width * 0.06, y: centerPoint.y),
            controlPoint2: rightPoint)
        
        return eyePath;
    }
    
    // MARK: Handling pan gestures.
    
    @objc fileprivate func panGestureAction(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            touchPoint = sender.location(in: self)
        
        case .changed:
            let currentPoint = sender.location(in: self)
            // Change rate value
            rateValue = rateValue + Float((currentPoint.y - touchPoint!.y) / self.bounds.height * rateDragSensitivity)
            // Save current point
            touchPoint = currentPoint
        
        case .ended:
             touchPoint = nil
            
        default:
            break
        }
    }
}

extension EmojiRateView : UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return recognizeSimultanousGestures
    }
}

