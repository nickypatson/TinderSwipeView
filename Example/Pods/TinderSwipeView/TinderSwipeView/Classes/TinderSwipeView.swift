//
//  TinderView.swift
//  TinderSwipeView
//
//  Created by Nick on 11/05/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

let inset : CGFloat = 10

public protocol TinderSwipeViewDelegate: class {
    
    func dummyAnimationDone()
    func currentCardStatus(card: Any, distance: CGFloat)
    func fallbackCard(model:Any)
    func didSelectCard(model:Any)
    func cardGoesLeft(model: Any)
    func cardGoesRight(model: Any)
    func undoCardsDone(model: Any)
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
    fileprivate var loadedCards = [TinderCard]()
    fileprivate var currentCard : TinderCard!
    
    public weak var delegate: TinderSwipeViewDelegate?
    
    fileprivate let contentView: ContentView?
    public typealias ContentView = (_ index: Int, _ frame: CGRect, _ element:Element) -> (UIView)
    
    public init(frame: CGRect,
                contentView: @escaping ContentView, bufferSize : Int = 3) {
        self.contentView = contentView
        self.bufferSize = bufferSize
        super.init(frame: frame)
    }
    
    override private init(frame: CGRect) {
        fatalError("Please use init(frame:,overlayGenerator)")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Please use init(frame:,overlayGenerator)")
    }
    
    /*
     * Showing Tinder cards to view
     */
    public func showTinderCards(with elements: [Element] ,isDummyShow: Bool = true) {
        
        if elements.isEmpty {
            return
        }
        
        allCards.append(contentsOf: elements)
        
        for (i,element) in elements.enumerated() {
            
            if loadedCards.count < bufferSize {
                
                let cardView = self.createTinderCard(index: i, element: element)
                if loadedCards.isEmpty {
                    self.addSubview(cardView)
                } else {
                    self.insertSubview(cardView, belowSubview: loadedCards.last!)
                }
                loadedCards.append(cardView)
            }
        }
        
        animateCardAfterSwiping()
        
        if isDummyShow{
            perform(#selector(loadAnimation), with: nil, afterDelay: 1.0)
        }
    }
    
    /*
     * Adding additional cards
     */
    public func appendTinderCards(with elements: [Element]) {
        
        if elements.isEmpty {
            return
        }
    }
    
    /*
     * Creating invidual cards
     */
    fileprivate func createTinderCard(index:Int,element: Element) -> TinderCard {
        
        let card = TinderCard(frame: CGRect(x: inset, y: inset + (CGFloat(loadedCards.count) * self.sepeatorDistance), width: bounds.width - (inset * 2), height: bounds.height - (CGFloat(bufferSize) * sepeatorDistance) - (inset * 2) ))
        card.delegate = self
        card.model = element
        card.addContentView(view: (self.contentView?(index, card.bounds, element)))
        return card
    }
    
    /*
     * Animating cards
     */
    fileprivate func animateCardAfterSwiping() {
        
        if loadedCards.isEmpty{
            self.delegate?.endOfCardsReached()
            return
        }
        
        for (i,card) in loadedCards.enumerated() {
            
            UIView.animate(withDuration: 0.5, animations: {
                card.isUserInteractionEnabled = i == 0 ? true : false
                var frame = card.frame
                frame.origin.y = inset + (CGFloat(i) * self.sepeatorDistance)
                card.frame = frame
            })
        }
    }
    
    /*
     * Loading animation
     */
    @objc private func loadAnimation() {
        
        guard let dummyCard = loadedCards.first else {
            return
        }
        dummyCard.shakeAnimationCard(completion: { (_) in
            self.delegate?.dummyAnimationDone()
        })
    }
    
    /*
     * Removing currrent card and add new cards to view
     */
    fileprivate func removeCardAndAddNewCard(){
        
        index += 1
        let card = loadedCards.first!
        card.index = index
        Timer.scheduledTimer(timeInterval: 1.01, target: self, selector: #selector(enableUndoButton), userInfo: card, repeats: false)
        loadedCards.remove(at: 0)
        
        if (index + loadedCards.count) < allCards.count {
            let tinderCard = createTinderCard(index: index + loadedCards.count, element: allCards[index + loadedCards.count])
            self.insertSubview(tinderCard, belowSubview: loadedCards.last!)
            loadedCards.append(tinderCard)
        }
        
        animateCardAfterSwiping()
    }
    
    /*
     * Left swipe action
     */
    public func makeLeftSwipeAction() {
        if let card = loadedCards.first {
            card.leftClickAction()
        }
    }
    
    /*
     * Right swipe action
     */
    public func makeRightSwipeAction() {
        if let card = loadedCards.first {
            card.rightClickAction()
        }
    }
    
    /*
     * Undo button pressed
     */
    public func undoCurrentTinderCard() {
        
        guard let undoCard = currentCard else{
            return
        }
        
        index -= 1
        if loadedCards.count == bufferSize {
            let lastCard = loadedCards.last
            lastCard?.rollBackCard()
            loadedCards.removeLast()
        }
        
        undoCard.layer.removeAllAnimations()
        self.insertSubview(undoCard, aboveSubview: loadedCards.first!)
        loadedCards.insert(undoCard, at: 0)
        undoCard.makeUndoAction()
        animateCardAfterSwiping()
        delegate?.undoCardsDone(model: undoCard.model!)
        currentCard = nil
    }
    
    /*
     * Enabling undo button
     */
    @objc private func enableUndoButton(timer: Timer){
        
        let card = timer.userInfo as! TinderCard
        if card.index == index{
            currentCard = card
        }
    }
}
// MARK: TinderCardDelegate Methods
extension TinderSwipeView : TinderCardDelegate {
    
    func didSelectCard(card: TinderCard) {
        self.delegate?.didSelectCard(model: card.model!)
    }
    
    func fallbackCard(card: TinderCard) {
        self.delegate?.fallbackCard(model: card.model!)
    }
    
    func cardGoesRight(card: TinderCard) {
        removeCardAndAddNewCard()
        self.delegate?.cardGoesRight(model: card.model!)
    }
    
    func cardGoesLeft(card: TinderCard) {
        removeCardAndAddNewCard()
        self.delegate?.cardGoesLeft(model: card.model!)
    }
    
    func currentCardStatus(card: TinderCard, distance: CGFloat) {
        self.delegate?.currentCardStatus(card: card, distance: distance)
    }
}
