//
//  BackgroundView.m
//  testingTinder
//
//  Created by Nicky on 11/16/17.
//  Copyright © 2017 Nicky. All rights reserved.
//
static const int MAX_BUFFER_SIZE = 3;
static const int SEPERATOR_DISTANCE = 8;
static const float TOPYAXIS = 75;

#import "BackgroundView.h"

@implementation BackgroundView{
    NSInteger currentIndex;
    NSMutableArray *_currentLoadedCardsArray,*_allCardsArray;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setUpView];
    }
    return self;
}

-(void)setUpView{
    
    self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1];
    _valueArray = @[@"first",@"second",@"third",@"fourth",@"last",@"first",@"second",@"third",@"fourth",@"last"];
    _allCardsArray = [[NSMutableArray alloc] init];
    _currentLoadedCardsArray = [[NSMutableArray alloc] init];
    currentIndex = 0;
    [self loadCards];
}

-(void)loadCards{
    
    if (_valueArray.count > 0){
        NSInteger num_currentLoadedCardsArrayCap =(([_valueArray count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[_valueArray count]);
        for (int i = 0; i<[_valueArray count]; i++) {
            TinderViewCard *newCard = [self createDraggableViewWithDataAtIndex:i];
            [_allCardsArray addObject:newCard];
            
            if (i<num_currentLoadedCardsArrayCap) {
                [_currentLoadedCardsArray addObject:newCard];
            }
        }
        
        for (int i = 0; i<[_currentLoadedCardsArray count]; i++) {
            if (i>0) {
                [self insertSubview:[_currentLoadedCardsArray objectAtIndex:i] belowSubview:[_currentLoadedCardsArray objectAtIndex:i-1]];
            } else {
                [self addSubview:[_currentLoadedCardsArray objectAtIndex:i]];
            }
            currentIndex++;
        }
        
        [self animateCardAfterSwiping];
        
    }
}

-(TinderViewCard *)createDraggableViewWithDataAtIndex:(NSInteger)index{
    
    TinderViewCard *card = [[TinderViewCard alloc]initWithFrame:CGRectMake(10, TOPYAXIS, self.frame.size.width-20, self.frame.size.height - TOPYAXIS - 200)];
    card.delegate = self;
    return card;
}


//%%% action called when the card goes to the left.
-(void)cardSwipedLeft:(UIView *)card;{
    [self removeObjectAndAddNewValues];
}

//%%% action called when the card goes to the right.
-(void)cardSwipedRight:(UIView *)card{
    [self removeObjectAndAddNewValues];
}

-(void)updateCardView:(UIView *)card withDistance:(CGFloat)distance{
    //NSLog(@"%f",distance);
    
    float ratio = MIN(fabs(distance/(self.frame.size.width/2)),1);
    NSLog(@"%f",ratio);
//    //for (int i = 1; i<_currentLoadedCardsArray.count; i++) {
//        TinderViewCard *selectedCard = (TinderViewCard*)_currentLoadedCardsArray[1];
//        CGRect frame = selectedCard.frame;
//        frame.origin.y = TOPYAXIS + (SEPERATOR_DISTANCE * 1)  - (1 * SEPERATOR_DISTANCE * ratio);
//        NSLog(@"y %f",(TOPYAXIS + (SEPERATOR_DISTANCE * 1)  - (1 * SEPERATOR_DISTANCE * ratio)));
//        selectedCard.frame = frame;
// //  }
}

-(void)removeObjectAndAddNewValues{

    [_currentLoadedCardsArray removeObjectAtIndex:0];
    if (currentIndex < [_allCardsArray count]) {
        
        TinderViewCard *card = (TinderViewCard*)[_allCardsArray objectAtIndex:currentIndex];
        CGRect frame = card.frame;
        frame.origin.y =  TOPYAXIS  + (MAX_BUFFER_SIZE  * SEPERATOR_DISTANCE);
        card.frame = frame;
        [_currentLoadedCardsArray addObject:card];
        currentIndex++;
        [self insertSubview:[_currentLoadedCardsArray objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[_currentLoadedCardsArray objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        [self animateCardAfterSwiping];
    }
}

-(void)animateCardAfterSwiping{
    
    for (int i = 0; i<_currentLoadedCardsArray.count; i++) {
        TinderViewCard *card = (TinderViewCard*)_currentLoadedCardsArray[i];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = card.frame;
            frame.origin.y = TOPYAXIS + (i * SEPERATOR_DISTANCE);
            card.frame = frame;
        }];
    }
}

@end
