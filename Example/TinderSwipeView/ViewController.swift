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
    
    let userModels : [UserModel] =  {
        var model : [UserModel] = []
        for n in 1...10 {
            model.append(UserModel(name: names[Int(arc4random_uniform(UInt32(names.count)))], age: "\(n)"))
        }
        return model
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overlayGenerator: ( CGRect,UserModel) -> (UIView) = { (frame: CGRect , userModel:UserModel) -> (UIView) in
            
            let containerView = UIView(frame: frame)
            
            let backGroundImageView = UIImageView(frame:containerView.bounds)
            backGroundImageView.image = UIImage(named:String(Int(1 + arc4random() % (8 - 1))))
            backGroundImageView.contentMode = .scaleAspectFill
            backGroundImageView.clipsToBounds = true;
            containerView.addSubview(backGroundImageView)
            
            let profileImageView = UIImageView(frame:CGRect(x: 20, y: frame.size.height - 80, width: 60, height: 60))
            profileImageView.image =  #imageLiteral(resourceName: "profileimage")
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.layer.cornerRadius = 25
            profileImageView.clipsToBounds = true
            containerView.addSubview(profileImageView)
            
            let labelText = UILabel(frame:CGRect(x: 90, y: frame.size.height - 80, width: frame.size.width - 100, height: 60))
            let attributedText = NSMutableAttributedString(string: userModel.name, attributes: [.foregroundColor: UIColor.white,.font:UIFont.boldSystemFont(ofSize: 25)])
            attributedText.append(NSAttributedString(string: "\n\( userModel.age!) mins", attributes: [.foregroundColor: UIColor.white,.font:UIFont.systemFont(ofSize: 18)]))
            labelText.attributedText = attributedText
            labelText.numberOfLines = 2
            containerView.addSubview(labelText)
            
            return containerView
            
        }
        
        swipeView = TinderSwipeView<UserModel>(frame: viewContainer.bounds, overlayGenerator: overlayGenerator)
        viewContainer.addSubview(swipeView)
        swipeView.showTinderCards(with: userModels)
        
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

}

extension ViewController : TinderSwipeViewDelegate{
    
    func currentCardStatus(card object: Any, distance: CGFloat) {
        print(distance)
    }
    
    func dummyAnimationDone() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
            self.viewNavigation.alpha = 1.0
        }, completion: nil)
    }
    
    func cardGoesLeft(_ object: Any) {
        
    }
    
    func cardGoesRight(_ object: Any) {
        
    }
    
    func endOfCardsReached() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.viewNavigation.alpha = 0.0
        }, completion: nil)
    }
}

