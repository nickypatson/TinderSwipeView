//
//  BackgroundView.h
//  testingTinder
//
//  Created by Nicky on 11/16/17.
//  Copyright © 2017 Nicky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TinderViewCard.h"

@interface BackgroundView : UIView<TinderViewCellDelegate>

@property (retain,nonatomic)NSArray* valueArray; 


@end
