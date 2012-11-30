//
//  ViewController.h
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameboardView.h"

@class MyButton;

@interface ViewController : UIViewController<BoardDelegate>

@property (weak, nonatomic) IBOutlet GameboardView *gameboardView;
@property (weak, nonatomic) IBOutlet MyButton *die1;
@property (weak, nonatomic) IBOutlet MyButton *die2;
@property (weak, nonatomic) IBOutlet MyButton *startButton;

- (IBAction)startPressed:(id)sender;
- (IBAction)die1Pressed:(id)sender;
- (IBAction)die2Pressed:(id)sender;

@end
