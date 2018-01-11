//
//  TinderCard.swift
//  testingTinderSwipe
//
//  Created by Nicky on 11/16/17.
//  Copyright © 2017 Nicky. All rights reserved.
//


let ACTION_MARGIN : CGFloat = 120
let SCALE_STRENGTH : CGFloat = 4
let SCALE_MAX : CGFloat = 0.93
let ROTATION_MAX : CGFloat = 1
let ROTATION_STRENGTH : CGFloat = 320

import UIKit

protocol TinderCardDelegate: NSObjectProtocol {
    func cardSwipedLeft(_ card: UIView)
    func cardSwipedRight(_ card: UIView)
    func updateCardView(_ card: UIView, withDistance distance: CGFloat)
}

class TinderCard: UIView {
    
    var xFromCenter: CGFloat = 0.0
    var yFromCenter: CGFloat = 0.0
    var originalPoint = CGPoint.zero
    var imageViewStatus = UIImageView()
    
    weak var delegate: TinderCardDelegate?
    
    public init(frame: CGRect, value: String) {
        super.init(frame: frame)
        setupView(at: value)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(at value:String) {
        
        let randomNumber = Int(1 + arc4random() % (5 - 1))
        let profileImageView = UIImageView(frame:bounds)
        profileImageView.image = UIImage(named:String(randomNumber))
        profileImageView.contentMode = .scaleToFill
        profileImageView.clipsToBounds = true;
        addSubview(profileImageView)
        
        imageViewStatus = UIImageView(frame: CGRect(x: (frame.size.width / 2) - 37.5, y: 25, width: 75, height: 75))
        imageViewStatus.image = UIImage(named: "btn_like_pressed")
        imageViewStatus.alpha = 0
        addSubview(imageViewStatus)
        
        layer.cornerRadius = 10
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0.5, height: 3)
        layer.shadowColor = UIColor.darkGray.cgColor
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.beingDragged))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func beingDragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        xFromCenter = gestureRecognizer.translation(in: self).x
        yFromCenter = gestureRecognizer.translation(in: self).y
        switch gestureRecognizer.state {
        // Keep swiping
        case .began:
            originalPoint = self.center;
            break;
        //in the middle of a swipe
        case .changed:
            let rotationStrength = min(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngel = .pi/8 * rotationStrength
            let scale = max(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)
            center = CGPoint(x: originalPoint.x + xFromCenter, y: originalPoint.y + yFromCenter)
            let transforms = CGAffineTransform(rotationAngle: rotationAngel)
            let scaleTransform: CGAffineTransform = transforms.scaledBy(x: scale, y: scale)
            self.transform = scaleTransform
            updateOverlay(xFromCenter)
            break;
           
        // swipe ended
        case .ended:
            afterSwipeAction()
            break;
            
        case .possible:break
        case .cancelled:break
        case .failed:break
        }
    }
    func updateOverlay(_ distance: CGFloat) {
        
        imageViewStatus.image = distance > 0 ? UIImage(named: "btn_like_pressed") : UIImage(named: "btn_skip_pressed")
        imageViewStatus.alpha = min(fabs(distance) / 100, 0.5)
        delegate?.updateCardView(self, withDistance: distance)
    }
    
    func afterSwipeAction() {
        if xFromCenter > CGFloat(ACTION_MARGIN) {
            rightAction()
        }
        else if xFromCenter < CGFloat(-ACTION_MARGIN) {
            leftAction()
        }
        else {
            //reseting image
            UIView.animate(withDuration: 0.3, animations: {
                self.center = self.originalPoint
                self.transform = CGAffineTransform(rotationAngle: 0)
                self.imageViewStatus.alpha = 0
            })
        }
        
    }
    
    func rightAction() {
        let finishPoint = CGPoint(x: 500, y: 2 * yFromCenter + originalPoint.y)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center = finishPoint
        }, completion: {(_) in
            self.removeFromSuperview()
        })
        delegate?.cardSwipedRight(self)
        print("WATCHOUT RIGHT")
    }
    
    func leftAction() {
        let finishPoint = CGPoint(x: -500, y: 2 * yFromCenter + originalPoint.y)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center = finishPoint
        }, completion: {(_) in
            self.removeFromSuperview()
        })
        delegate?.cardSwipedLeft(self)
        print("WATCHOUT LEFT")
    }
    
    // right click action
    func rightClickAction() {
        imageViewStatus.image = UIImage(named: "btn_like_pressed")
        let finishPoint = CGPoint(x: center.x + frame.size.width * 1.5, y: center.y)
        imageViewStatus.alpha = 0.5
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: 1)
            self.imageViewStatus.alpha = 1.0
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        delegate?.cardSwipedRight(self)
    }
    // left click action
    func leftClickAction() {
        imageViewStatus.image = UIImage(named: "btn_skip_pressed")
        let finishPoint = CGPoint(x: center.x - frame.size.width * 1.5, y: center.y)
        imageViewStatus.alpha = 0.5
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: -1)
            self.imageViewStatus.alpha = 1.0
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        delegate?.cardSwipedLeft(self)
    }
    
    func shakeCard()
    {
        let originalP: CGPoint = center
        imageViewStatus.image = UIImage(named: "btn_skip_pressed")
        UIView.animate(withDuration: 0.6, animations: {() -> Void in
            self.center = CGPoint(x: self.center.x - (self.frame.size.width / 2), y: self.center.y)
            self.transform = CGAffineTransform(rotationAngle: -0.2)
            self.imageViewStatus.alpha = 1.0
        }, completion: {(_ complete: Bool) -> Void in
            
            UIView.animate(withDuration: 0.6, animations: {() -> Void in
                self.imageViewStatus.alpha = 0
                self.center = originalP
                self.transform = CGAffineTransform(rotationAngle: 0)
            }, completion: {(_ complete: Bool) -> Void in
                self.imageViewStatus.image = UIImage(named: "btn_like_pressed")
                UIView.animate(withDuration: 0.6, animations: {() -> Void in
                    self.imageViewStatus.alpha = 1
                    self.center = CGPoint(x: self.center.x + (self.frame.size.width / 2), y: self.center.y)
                    self.transform = CGAffineTransform(rotationAngle: 0.2)
                }, completion: {(_ complete: Bool) -> Void in
                    UIView.animate(withDuration: 0.6, animations: {() -> Void in
                        self.imageViewStatus.alpha = 0
                        self.center = originalP
                        self.transform = CGAffineTransform(rotationAngle: 0)
                    }) { _ in }
                })
            })
            
        })
        
    }
}

