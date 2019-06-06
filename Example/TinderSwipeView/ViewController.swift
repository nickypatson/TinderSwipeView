//
//  ViewController.swift
//  TinderSwipeView
//
//  Created by Nick on 11/05/19.
//  Copyright © 2019 Nick. All rights reserved.
//

let names = ["Adam Gontier","Matt Walst","Brad Walst","Neil Sanderson","Barry Stock","Nicky Patson"]

import UIKit
import TinderSwipeView

class ViewController: UIViewController {
    
    private var swipeView: TinderSwipeView<UserModel>!{
        didSet{
            self.swipeView.delegate = self
        }
    }
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewNavigation: UIView!{
        didSet{
            self.viewNavigation.alpha = 0.0
        }
    }
    @IBOutlet weak var emojiView: EmojiRateView!
    
    let userModels : [UserModel] =  {
        var model : [UserModel] = []
        for n in 1...30 {
            model.append(UserModel(name: names[Int(arc4random_uniform(UInt32(names.count)))], num: "\(n)"))
        }
        return model
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dynamically create view for each tinder card
        let contentView: (Int, CGRect, UserModel) -> (UIView) = { (index: Int ,frame: CGRect , userModel: UserModel) -> (UIView) in
            
            // Programitcally creating content view
            if index % 2 != 0 {
                return self.programticViewForOverlay(frame: frame, userModel: userModel)
            }
            // loading contentview from nib 
            else{
                let customView = CustomView(frame: frame)
                customView.userModel = userModel
                customView.buttonAction.addTarget(self, action: #selector(self.customViewButtonSelected), for: UIControl.Event.touchUpInside)
                return customView
            }
        }
                
        swipeView = TinderSwipeView<UserModel>(frame: viewContainer.bounds, contentView: contentView)
        viewContainer.addSubview(swipeView)
        swipeView.showTinderCards(with: userModels ,isDummyShow: true)
    }
    
    private func programticViewForOverlay(frame:CGRect, userModel:UserModel) -> UIView{
    
        let containerView = UIView(frame: frame)
        
        let backGroundImageView = UIImageView(frame:containerView.bounds)
        backGroundImageView.image = UIImage(named:String(Int(1 + arc4random() % (8 - 1))))
        backGroundImageView.contentMode = .scaleAspectFill
        backGroundImageView.clipsToBounds = true;
        containerView.addSubview(backGroundImageView)
        
        let profileImageView = UIImageView(frame:CGRect(x: 25, y: frame.size.height - 80, width: 60, height: 60))
        profileImageView.image =  #imageLiteral(resourceName: "profileimage")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        containerView.addSubview(profileImageView)
        
        let labelText = UILabel(frame:CGRect(x: 90, y: frame.size.height - 80, width: frame.size.width - 100, height: 60))
        labelText.attributedText = self.attributeStringForModel(userModel: userModel)
        labelText.numberOfLines = 2
        containerView.addSubview(labelText)
        
        return containerView
    }
    
    @objc func customViewButtonSelected(button:UIButton){
        
        if let customView = button.superview(of: CustomView.self) , let userModel = customView.userModel{
            print("button selected for \(userModel.name!)")
        }
        
    }
    
    private func attributeStringForModel(userModel:UserModel) -> NSAttributedString{
        
        let attributedText = NSMutableAttributedString(string: userModel.name, attributes: [.foregroundColor: UIColor.white,.font:UIFont.boldSystemFont(ofSize: 25)])
        attributedText.append(NSAttributedString(string: "\nnums :\( userModel.num!) (programitically)", attributes: [.foregroundColor: UIColor.white,.font:UIFont.systemFont(ofSize: 18)]))
        return attributedText
    }
    

    @IBAction func leftSwipeAction(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.makeLeftSwipeAction()
        }
    }
    
    @IBAction func rightSwipeAction(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.makeRightSwipeAction()
        }
    }
    
    @IBAction func undoButtonPressed(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.undoCurrentTinderCard()
        }
    }
}

extension ViewController : TinderSwipeViewDelegate{
    
    func dummyAnimationDone() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
            self.viewNavigation.alpha = 1.0
        }, completion: nil)
        print("Watch out shake action")
    }
    
    func didSelectCard(model: Any) {
        print("Selected card")
    }
    
    func fallbackCard(model: Any) {
        emojiView.rateValue =  2.5
        let userModel = model as! UserModel
        print("Cancelling \(userModel.name!)")
    }
    
    func cardGoesLeft(model: Any) {
        emojiView.rateValue =  2.5
        let userModel = model as! UserModel
        print("Watchout Left \(userModel.name!)")
    }
    
    func cardGoesRight(model : Any) {
        emojiView.rateValue =  2.5
        let userModel = model as! UserModel
        print("Watchout Right \(userModel.name!)")
    }
    
    func undoCardsDone(model: Any) {
        emojiView.rateValue =  2.5
        let userModel = model as! UserModel
        print("Reverting done \(userModel.name!)")
    }
    
    func endOfCardsReached() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.viewNavigation.alpha = 0.0
        }, completion: nil)
         print("End of all cards")
    }
    
    func currentCardStatus(card object: Any, distance: CGFloat) {
        if distance == 0 {
            emojiView.rateValue =  2.5
        }else{
            let value = Float(min(abs(distance/100), 1.0) * 5)
            let sorted = distance > 0  ? 2.5 + (value * 5) / 10  : 2.5 - (value * 5) / 10
            emojiView.rateValue =  sorted
        }
        print(distance)
    }
}

extension UIView {
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.map { $0.superview(of: type)! }
    }
    
    func subview<T>(of type: T.Type) -> T? {
        return subviews.compactMap { $0 as? T ?? $0.subview(of: type) }.first
    }
}
