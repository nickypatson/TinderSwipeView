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
    var imageView = UIImageView()
    
    weak var delegate: TinderCardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        imageView = UIImageView(frame: CGRect(x: (frame.size.width / 2) - 37.5, y: frame.size.height - 75 - 50, width: 75, height: 75))
        imageView.image = UIImage(named: "yesButton")
        imageView.alpha = 0
        let textLabel = UILabel(frame: CGRect(x: 20, y: 50, width: frame.size.width - 40, height: frame.size.width - 100))
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        let attributedString = NSMutableAttributedString(string: "First Contact\n", attributes: [.foregroundColor: UIColor.orange, .font: UIFont.boldSystemFont(ofSize: 20.0)])
        attributedString.append(NSAttributedString(string: "Company\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)]))
        attributedString.append(NSAttributedString(string: "Title\nCity\nCountry", attributes: [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 15.0)]))
        textLabel.attributedText = attributedString
        
        addSubview(imageView)
        addSubview(textLabel)
        
        layer.cornerRadius = 10
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0.5, height: 3)
        layer.shadowColor = UIColor.gray.cgColor
        backgroundColor = .white
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.beingDragged))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func beingDragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        xFromCenter = gestureRecognizer.translation(in: self).x
        yFromCenter = gestureRecognizer.translation(in: self).y
        switch gestureRecognizer.state {
        //%%% just started swiping
        case .began:
            originalPoint = self.center;
            break;
            
        //%%% in the middle of a swipe
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
            
        case .ended:
            afterSwipeAction()
            break;
            
        case .possible:break
        case .cancelled:break
        case .failed:break
        }
    }
    func updateOverlay(_ distance: CGFloat) {
        
        imageView.image = distance > 0 ? UIImage(named: "yesButton") : UIImage(named: "noButton")
        imageView.alpha = min(fabs(distance) / 100, 0.5)
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
            //%%% resets the card
            UIView.animate(withDuration: 0.3, animations: {
                self.center = self.originalPoint
                self.transform = CGAffineTransform(rotationAngle: 0)
                self.imageView.alpha = 0
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
        imageView.image = UIImage(named: "yesButton")
        let finishPoint = CGPoint(x: center.x + frame.size.width * 1.5, y: center.y)
        imageView.alpha = 0.5
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: 1)
            self.imageView.alpha = 1.0
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        delegate?.cardSwipedRight(self)
    }
    // left click action
    func leftClickAction() {
        imageView.image = UIImage(named: "noButton")
        let finishPoint = CGPoint(x: center.x - frame.size.width * 1.5, y: center.y)
        imageView.alpha = 0.5
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: -1)
            self.imageView.alpha = 1.0
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        delegate?.cardSwipedLeft(self)
    }
    
    func shakeCard()
    {
        let originalP: CGPoint = center
        imageView.image = UIImage(named: "noButton")
        UIView.animate(withDuration: 0.6, animations: {() -> Void in
            self.center = CGPoint(x: self.center.x - (self.frame.size.width / 2), y: self.center.y)
            self.transform = CGAffineTransform(rotationAngle: -0.2)
            self.imageView.alpha = 1.0
        }, completion: {(_ complete: Bool) -> Void in
            
            UIView.animate(withDuration: 0.6, animations: {() -> Void in
                self.imageView.alpha = 0
                self.center = originalP
                self.transform = CGAffineTransform(rotationAngle: 0)
            }, completion: {(_ complete: Bool) -> Void in
                self.imageView.image = UIImage(named: "yesButton")
                UIView.animate(withDuration: 0.6, animations: {() -> Void in
                    self.imageView.alpha = 1
                    self.center = CGPoint(x: self.center.x + (self.frame.size.width / 2), y: self.center.y)
                    self.transform = CGAffineTransform(rotationAngle: 0.2)
                }, completion: {(_ complete: Bool) -> Void in
                    UIView.animate(withDuration: 0.6, animations: {() -> Void in
                        self.imageView.alpha = 0
                        self.center = originalP
                        self.transform = CGAffineTransform(rotationAngle: 0)
                    }) { _ in }
                })
            })
            
        })
        
    }
}

