//
//  ViewController.m
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "ViewController.h"

#import "Game.h"
#import "MyButton.h"
#import "UIColor+Gammon.h"


@interface ViewController ()

@property (nonatomic) Game *game;

@end

@implementation ViewController


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.game = [[Game alloc] init];
  self.gameboardView.game = self.game;
  
  self.startButton.borderColor = [UIColor darkBrownColor];
  self.startButton.topColor = [UIColor middleBrownColor];
  self.startButton.bottomColor = [UIColor lightBrownColor];
  
  [self.game addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
  self.game.delegate = self.gameboardView;
  
  self.gameboardView.delegate = self;
  
  [self restart];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)restart
{
  self.die1.hidden = NO;
  self.die2.hidden = NO;
  [self.game restart];
}


#pragma mark - Actions


- (IBAction)startPressed:(id)sender {
  [self restart];
}


- (IBAction)die1Pressed:(id)sender {
  [self.game next];
}


- (IBAction)die2Pressed:(id)sender {
  [self.game next];
}


- (IBAction)rollPressed:(id)sender {
  [self.game next];
}


#pragma mark - BoardDelegate


- (void)pipTapped:(NSUInteger)index
{
  NSLog(@"pip tapped: %d", index);
  if (self.game.state != Ended && [self.game movesLeft]) {
    [self.game moveFrom:index by:[self.game.availableMoves[0] unsignedIntegerValue]];
  }
}


#pragma mark - KVO


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  NSLog(@"change: %@ %@", keyPath, change);
  if (object == self.game && [keyPath isEqualToString:@"state"]) {
    NSArray *roll = self.game.roll;
    NSLog(@"roll: %@", roll);
    self.die1.titleLabel.text = [roll[0] stringValue];
    self.die2.titleLabel.text = [roll[1] stringValue];
    switch (self.game.state) {
      case Ended:
        self.die1.hidden = YES;
        self.die2.hidden = YES;
        break;
        
      case WhitesTurn:
        self.die1.hidden = NO;
        self.die2.hidden = NO;
        self.die1.topColor = [UIColor lightGrayColor];
        self.die1.bottomColor = [UIColor whiteColor];
        self.die2.topColor = [UIColor lightGrayColor];
        self.die2.bottomColor = [UIColor whiteColor];
        [self.die1 setNeedsDisplay];
        [self.die2 setNeedsDisplay];
        break;
        
      case BlacksTurn:
        self.die1.hidden = NO;
        self.die2.hidden = NO;
        self.die1.topColor = [UIColor darkGrayColor];
        self.die1.bottomColor = [UIColor lightGrayColor];
        self.die2.topColor = [UIColor darkGrayColor];
        self.die2.bottomColor = [UIColor lightGrayColor];
        [self.die1 setNeedsDisplay];
        [self.die2 setNeedsDisplay];
        break;
        
      default:
        break;
    }
  }
}


@end
