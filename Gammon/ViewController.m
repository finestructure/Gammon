//
//  ViewController.m
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "ViewController.h"

#import "Game.h"
#import "GameboardView.h"


@interface ViewController ()

@property (nonatomic) Game *game;

@end

@implementation ViewController


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.game = [[Game alloc] init];
  self.gameboardView.game = self.game;
  
  self.die1.titleLabel.text = @"";
  self.die2.titleLabel.text = @"";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startPressed:(id)sender {
  NSArray *roll = [self.game roll];
  self.die1.titleLabel.text = [roll[0] stringValue];
  self.die2.titleLabel.text = [roll[1] stringValue];
}


@end
