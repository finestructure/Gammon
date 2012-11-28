//
//  ViewController.h
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameboardView;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet GameboardView *gameboardView;
@property (weak, nonatomic) IBOutlet UIButton *die1;
@property (weak, nonatomic) IBOutlet UIButton *die2;

- (IBAction)startPressed:(id)sender;

@end
