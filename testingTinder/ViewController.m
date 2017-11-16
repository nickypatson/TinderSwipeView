//
//  ViewController.m
//  testingTinder
//
//  Created by Nicky on 11/16/17.
//  Copyright © 2017 Nicky. All rights reserved.
//

#import "ViewController.h"
#import "BackgroundView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BackgroundView *draggableBackground = [[BackgroundView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
