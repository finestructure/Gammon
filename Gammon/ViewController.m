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
  GameboardView *v = (GameboardView *)self.view;
  v.game = self.game;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
