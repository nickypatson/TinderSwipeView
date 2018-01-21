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
    @IBOutlet weak var buttonUndo: UIButton!
    @IBOutlet weak var viewActions: UIView!
    @IBOutlet weak var viewActionHeightConstrain: NSLayoutConstraint!
    
    var currentIndex = 0
    var isMakeUndo = false
    var currentLoadedCardsArray = [TinderCard]()
    var allCardsArray = [TinderCard]()
    var valueArray = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36"]
    
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
        UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveLinear, animations: {
            self.viewActions.alpha = 1.0
        }, completion: nil)
    }
    
    func createDraggableViewWithData(at index: Int , value :String) -> TinderCard {
        
        let card = TinderCard(frame: CGRect(x: 10, y: 0, width: viewTinderBackGround.frame.size.width - 20 , height: viewTinderBackGround.frame.size.height - 40) ,value : value)
        card.delegate = self
        return card
    }
    
    func removeObjectAndAddNewValues() {
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(enableUndoButton), userInfo: nil, repeats: false)
        currentLoadedCardsArray.remove(at: 0)
        if currentIndex < allCardsArray.count {
            let card = allCardsArray[currentIndex]
            var frame = card.frame
            frame.origin.y = CGFloat(MAX_BUFFER_SIZE * SEPERATOR_DISTANCE)
            card.frame = frame
            currentLoadedCardsArray.append(card)
            currentIndex += 1
            viewTinderBackGround.insertSubview(currentLoadedCardsArray[MAX_BUFFER_SIZE - 1], belowSubview: currentLoadedCardsArray[MAX_BUFFER_SIZE - 2])
        }
        print(currentIndex)
        animateCardAfterSwiping()
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
        
        let card = currentLoadedCardsArray.first
        card?.leftClickAction()
        DispatchQueue.main.async {
           self.buttonUndo.isHidden = true
        }
    }
    
    @IBAction func LikeButtonAction(_ sender: Any) {
        
        let card = currentLoadedCardsArray.first
        card?.rightClickAction()
        DispatchQueue.main.async {
            self.buttonUndo.isHidden = true
        }
    }
    
    @IBAction func undoButtonAction(_ sender: Any) {
        
        if !isMakeUndo {
            isMakeUndo = true
            buttonUndo.isHidden = true
            currentIndex -= 1
            
            let undoCard = allCardsArray[currentIndex-currentLoadedCardsArray.count]
            currentLoadedCardsArray.insert(undoCard, at: 0)
            viewTinderBackGround.addSubview(undoCard)
            undoCard.makeUndoAction()
            if (currentLoadedCardsArray.count > MAX_BUFFER_SIZE){
                currentLoadedCardsArray.last?.removeFromSuperview()
                currentLoadedCardsArray.removeLast()
            }else{
               currentIndex = allCardsArray.count
            }
            animateCardAfterSwiping()
            print(currentIndex)
        }
    }
    
    @objc func enableUndoButton(){
        
        buttonUndo.isHidden = false
        isMakeUndo = false
    }
}

extension ViewController : TinderCardDelegate{
    
    // action called when the card goes to the left.
    func cardSwipedLeft(_ card: TinderCard) {
        removeObjectAndAddNewValues()
    }
    // action called when the card goes to the right.
    func cardSwipedRight(_ card: TinderCard) {
        removeObjectAndAddNewValues()
    }
    func updateCardView(_ card: TinderCard, withDistance distance: CGFloat) {
        //Log(@"%f",distance);
    }
}

