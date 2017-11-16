//
//  TinderViewCard.h
//  RKSwipeCards
//
//  Created by Nicky on 11/16/17.
//  Copyright © 2017 Nicky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TinderViewCellDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
-(void)updateCardView:(UIView *)card withDistance:(CGFloat)distance;

@end

@interface TinderViewCard : UIView

@property (weak) id <TinderViewCellDelegate> delegate;
@property (nonatomic,strong)UILabel* textLabel;


@end
