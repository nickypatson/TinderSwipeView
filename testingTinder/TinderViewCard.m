//
//  TinderViewCell.m
//  RKSwipeCards
//
//  Created by Nicky on 11/16/17.
//  Copyright © 2017 Nicky. All rights reserved.
//
#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#import "TinderViewCard.h"

@implementation TinderViewCard{
    CGFloat xFromCenter;
    CGFloat yFromCenter;
    CGPoint originalPoint;
    
    UIImageView *imageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    imageView =[[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width/2) - 37.5, self.frame.size.height - 75 - 50, 75, 75)];
    [imageView setImage:[UIImage imageNamed:@"yesButton"]];
    imageView.alpha = 0;

    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, self.frame.size.width-40, self.frame.size.width-100)];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    _textLabel.numberOfLines = 0;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:@"First Contact\n" attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor],NSFontAttributeName : [UIFont boldSystemFontOfSize:20.0f]}];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"Company\n" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName : [UIFont systemFontOfSize:17.0f]}]];
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"Title\nCity, Country\n" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName : [UIFont systemFontOfSize:15.0f]}]];
    _textLabel.attributedText = attributedString;

    
    [self addSubview:imageView];
    [self addSubview:_textLabel];
    
    self.layer.cornerRadius = 10;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowOffset = CGSizeMake(0.5, 3);
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.backgroundColor = [UIColor whiteColor];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    [self addGestureRecognizer:panGestureRecognizer];
}


-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer{

    xFromCenter = [gestureRecognizer translationInView:self].x;
    yFromCenter = [gestureRecognizer translationInView:self].y;
    
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            
            originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            self.center = CGPointMake(originalPoint.x + xFromCenter, originalPoint.y + yFromCenter);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}
-(void)updateOverlay:(CGFloat)distance{
    
    if (distance > 0){
        [imageView setImage:[UIImage imageNamed:@"yesButton"]];
    }else{
        [imageView setImage:[UIImage imageNamed:@"noButton"]];
    }
    imageView.alpha =  MIN(fabs(distance)/100, 0.5);
    [_delegate updateCardView:self withDistance:distance];
    
}
//%%% called when the card is let go
- (void)afterSwipeAction{
    
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             imageView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction{
    
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter + originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [_delegate cardSwipedRight:self];
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction{
    
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter + originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [_delegate cardSwipedLeft:self];
    NSLog(@"NO");
}

@end
