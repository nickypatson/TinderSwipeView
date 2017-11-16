//
//  TinderViewBackGround.swift
//  testingTinderSwipe
//
//  Created by Nicky on 11/16/17.
//  Copyright © 2017 Nicky. All rights reserved.
//

let  MAX_BUFFER_SIZE = 3;
let  SEPERATOR_DISTANCE = 8;
let  TOPYAXIS = 75;

import UIKit

class TinderViewBackGround: UIView {
    var currentIndex = 0
    var currentLoadedCardsArray = [TinderCard]()
    var allCardsArray = [TinderCard]()
    var valueArray = Array<String>()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        valueArray = ["first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last"]
        currentIndex = 0
        loadCards()
    }
    
    func loadCards() {
        if valueArray.count > 0 {
            let num_currentLoadedCardsArrayCap = (valueArray.count > MAX_BUFFER_SIZE) ? MAX_BUFFER_SIZE : valueArray.count
            
            for (i,_) in valueArray.enumerated() {
                let newCard = createDraggableViewWithData(at: i)
                allCardsArray.append(newCard)
                if i < num_currentLoadedCardsArrayCap {
                    currentLoadedCardsArray.append(newCard)
                }
            }
            
            
            for (i,_) in currentLoadedCardsArray.enumerated() {
                if i > 0 {
                    insertSubview(currentLoadedCardsArray[i], belowSubview: currentLoadedCardsArray[i - 1])
                }
                else {
                    addSubview(currentLoadedCardsArray[i])
                }
                currentIndex += 1
            }
            animateCardAfterSwiping()
        }
    }
    
    func createDraggableViewWithData(at index: Int) -> TinderCard {
        
        let card = TinderCard(frame: CGRect(x: 10, y: CGFloat(TOPYAXIS), width: frame.size.width - 20, height: frame.size.height - CGFloat(TOPYAXIS) - 200))
        card.delegate = self
        return card
    }
    
    func removeObjectAndAddNewValues() {
        
        currentLoadedCardsArray.remove(at: 0)
        if currentIndex < allCardsArray.count {
            let card = allCardsArray[currentIndex]
            var frame = card.frame
            frame.origin.y = CGFloat(TOPYAXIS + (MAX_BUFFER_SIZE * SEPERATOR_DISTANCE))
            card.frame = frame
            currentLoadedCardsArray.append(card)
            currentIndex += 1
            insertSubview(currentLoadedCardsArray[MAX_BUFFER_SIZE - 1], belowSubview: currentLoadedCardsArray[MAX_BUFFER_SIZE - 2])
            animateCardAfterSwiping()
        }
    }
    
    func animateCardAfterSwiping() {
        
        for (i,card) in currentLoadedCardsArray.enumerated() {
            UIView.animate(withDuration: 0.5, animations: {
                var frame = card.frame
                frame.origin.y = CGFloat(TOPYAXIS + (i * SEPERATOR_DISTANCE))
                card.frame = frame
            })
        }
    }
}

extension TinderViewBackGround : TinderCardDelegate{
    
    //%%% action called when the card goes to the left.
    func cardSwipedLeft(_ card: UIView) {
        removeObjectAndAddNewValues()
    }
    //%%% action called when the card goes to the right.
    func cardSwipedRight(_ card: UIView) {
        removeObjectAndAddNewValues()
    }
    
    func updateCardView(_ card: UIView, withDistance distance: CGFloat) {
        //NSLog(@"%f",distance);
        let ratio: Float = Float(min(fabs(distance / (frame.size.width / 2)), 1))
        print("\(ratio)")
    }
}
