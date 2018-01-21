//
//  ViewController.swift
//  testingTinderSwipe
//
//  Created by Nicky on 11/16/17.
//  Copyright © 2017 Nicky. All rights reserved.
//

let  MAX_BUFFER_SIZE = 3;
let  SEPERATOR_DISTANCE = 8;
let  TOPYAXIS = 75;

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var viewTinderBackGround: UIView!

   
    
    var currentIndex = 0
    var currentLoadedCardsArray = [TinderCard]()
    var allCardsArray = [TinderCard]()
    var valueArray = ["first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last","first", "second", "third", "fourth", "last", "first", "second", "third", "fourth", "last"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        loadCards()
    }
    
    
    func loadCards() {
        if valueArray.count > 0 {
            let num_currentLoadedCardsArrayCap = (valueArray.count > MAX_BUFFER_SIZE) ? MAX_BUFFER_SIZE : valueArray.count
            
            for (i,value) in valueArray.enumerated() {
                let newCard = createDraggableViewWithData(at: i,value: value)
                allCardsArray.append(newCard)
                if i < num_currentLoadedCardsArrayCap {
                    currentLoadedCardsArray.append(newCard)
                }
            }
            
            for (i,_) in currentLoadedCardsArray.enumerated() {
                if i > 0 {
                    viewTinderBackGround.insertSubview(currentLoadedCardsArray[i], belowSubview: currentLoadedCardsArray[i - 1])
                }
                else {
                    viewTinderBackGround.addSubview(currentLoadedCardsArray[i])
                }
                currentIndex += 1
            }
            animateCardAfterSwiping()
            
            self.perform(#selector(createDummyCard), with: nil, afterDelay: 1.0)
            
        }
    }
    
    @objc func createDummyCard() {
        let dummyCard = currentLoadedCardsArray.first;
        dummyCard?.shakeCard()
    }
    
    func createDraggableViewWithData(at index: Int , value :String) -> TinderCard {
        
        let card = TinderCard(frame: CGRect(x: 10, y: 0, width: viewTinderBackGround.frame.size.width - 20 , height: viewTinderBackGround.frame.size.height - 40) ,value : value)
        card.delegate = self
        return card
    }
    
    func removeObjectAndAddNewValues() {
        
        currentLoadedCardsArray.remove(at: 0)
        if currentIndex < allCardsArray.count {
            let card = allCardsArray[currentIndex]
            var frame = card.frame
            frame.origin.y = CGFloat(MAX_BUFFER_SIZE * SEPERATOR_DISTANCE)
            card.frame = frame
            currentLoadedCardsArray.append(card)
            currentIndex += 1
            viewTinderBackGround.insertSubview(currentLoadedCardsArray[MAX_BUFFER_SIZE - 1], belowSubview: currentLoadedCardsArray[MAX_BUFFER_SIZE - 2])
            animateCardAfterSwiping()
        }
    }
    
    func animateCardAfterSwiping() {
        
        for (i,card) in currentLoadedCardsArray.enumerated() {
            UIView.animate(withDuration: 0.5, animations: {
                var frame = card.frame
                frame.origin.y = CGFloat(i * SEPERATOR_DISTANCE)
                card.frame = frame
            })
        }
    }
    
    
    @IBAction func disLikeButtonAction(_ sender: Any) {
        let card  = currentLoadedCardsArray.first
        card?.leftClickAction()
    }
    @IBAction func LikeButtonAction(_ sender: Any) {
        let card  = currentLoadedCardsArray.first
        card?.rightClickAction()
    }
    
}

extension ViewController : TinderCardDelegate{
    
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
    }
}

