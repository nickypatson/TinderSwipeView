//
//  TinderView.swift
//  TinderSwipeView
//
//  Created by Nick on 11/05/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

let distance : CGFloat = 10

public protocol TinderSwipeViewDelegate: class {
    
    func dummyAnimationDone()
    func currentCardStatus(card: Any, distance: CGFloat)
    func cardGoesLeft(_ object: Any)
    func cardGoesRight(_ object: Any)
    func endOfCardsReached()
}

public class TinderSwipeView <Element>: UIView {
    
    var bufferSize: Int = 3 {
        didSet {
            bufferSize = bufferSize > 3 ? 3 : bufferSize
        }
    }
    public var sepeatorDistance : CGFloat = 8
    var index = 0

    fileprivate var allCards = [Element]()
    fileprivate var currentLoadedCards = [TinderCard]()
    
    public weak var delegate: TinderSwipeViewDelegate?
    
    fileprivate let overlayGenerator: OverlayGenerator?
    public typealias OverlayGenerator = (_ frame: CGRect, _ element:Element) -> (UIView)
    
    public init(frame: CGRect,
                overlayGenerator: @escaping OverlayGenerator, bufferSize : Int = 3) {
        self.overlayGenerator = overlayGenerator
        self.bufferSize = bufferSize
        super.init(frame: frame)
    }
    
    override private init(frame: CGRect) {
        fatalError("Please use init(frame:,overlayGenerator)")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Please use init(frame:,overlayGenerator)")
    }
    
    
    public func showTinderCards(with elements: [Element] ,isDummyShow: Bool = true) {
        
        if elements.isEmpty {
            return
        }
        
        allCards.append(contentsOf: elements)
        
        for element in elements {
            
            if currentLoadedCards.count < bufferSize {
                let cardView = self.createTinderCard(element: element)
                if currentLoadedCards.isEmpty {
                    self.addSubview(cardView)
                } else {
                    self.insertSubview(cardView, belowSubview: currentLoadedCards.last!)
                }
                currentLoadedCards.append(cardView)
            }
        }
        
        animateCardAfterSwiping()
        
        if isDummyShow{
            perform(#selector(loadAnimation), with: nil, afterDelay: 1.0)
        }
        
    }

    fileprivate func createTinderCard(element: Element) -> TinderCard {
        
        let cardView = TinderCard(frame: CGRect(x: distance, y: distance, width: bounds.width - (distance * 2), height: bounds.height - (CGFloat(bufferSize) * sepeatorDistance) - (distance * 2) ))
        cardView.delegate = self
        cardView.addOverlay(view: (self.overlayGenerator?(cardView.bounds, element)))
        return cardView
    }
    
    fileprivate func animateCardAfterSwiping() {
        
        if currentLoadedCards.isEmpty{
            self.delegate?.endOfCardsReached()
            return
        }
        
        for (i,card) in currentLoadedCards.enumerated() {
            
            UIView.animate(withDuration: 0.5, animations: {
                 card.isUserInteractionEnabled = i == 0 ? true : false
                var frame = card.frame
                frame.origin.y = distance + (CGFloat(i) * self.sepeatorDistance)
                card.frame = frame
            })
        }
    }
    
    @objc func loadAnimation() {
        
        guard let dummyCard = currentLoadedCards.first else {
            return
        }
        dummyCard.shakeAnimationCard(completion: { (_) in
            self.delegate?.dummyAnimationDone()
        })
    }

    
    public func makeLeftSwipeAction() {
        if let card = currentLoadedCards.first {
            card.leftClickAction()
        }
        
    }
    
    public func makeRightSwipeAction() {
        if let card = currentLoadedCards.first {
            card.rightClickAction()
        }
    }
    
    public func undoTinderCard() {
        
    }
    
    fileprivate func removeCardAndAddNewCard(){
        
        currentLoadedCards.remove(at: 0)
        index += 1
        if (index + currentLoadedCards.count) < allCards.count {
            let tinderCard = createTinderCard(element: allCards[index + currentLoadedCards.count])
            self.insertSubview(tinderCard, belowSubview: currentLoadedCards.last!)
            currentLoadedCards.append(tinderCard)
        }

        animateCardAfterSwiping()
    }

}


extension TinderSwipeView : TinderCardDelegate {
    
    func cardGoesRight(card: TinderCard) {
        removeCardAndAddNewCard()
    }
    
    func cardGoesLeft(card: TinderCard) {
        removeCardAndAddNewCard()
    }
    
    func currentCardStatus(card: TinderCard, distance: CGFloat) {
        self.delegate?.currentCardStatus(card: card, distance: distance)
    }
    
    
}
