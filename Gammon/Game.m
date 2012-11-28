//
//  Game.m
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "Game.h"
#import "Slot.h"


const NSUInteger kSlotCount = 24;


@implementation Game


- (id)init
{
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}


- (void)setup
{
  // We keep 24 slots and the bar in a single array describing the layout of the complete board.
  // Slot 0 contains checkers on the bar.
  NSMutableArray *slots = [NSMutableArray arrayWithCapacity:kSlotCount+1];
  for (NSUInteger i = 0; i < kSlotCount+1; ++i) {
    [slots addObject:[[Slot alloc] init]];
  }
  
  // Board layout, format: checker count, color, index
  NSArray *layout = @[
    @[@2, @(White), @1],
    @[@5, @(White), @12],
    @[@3, @(White), @17],
    @[@5, @(White), @19],
    @[@5, @(Black), @6],
    @[@3, @(Black), @8],
    @[@5, @(Black), @13],
    @[@2, @(Black), @24]
  ];
  
  for (NSArray *item in layout) {
    NSUInteger count = [[item objectAtIndex:0] unsignedIntegerValue];
    CheckerColor color = [[item objectAtIndex:1] unsignedIntegerValue];
    NSUInteger index = [[item objectAtIndex:2] unsignedIntegerValue];

    Slot *s = [slots objectAtIndex:index];
    s.color = color;
    s.count = count;
  }
  
  self.slots = slots;
}


- (NSArray *)roll
{
  NSUInteger r1 = [self randomWithMax:5] +1;
  NSUInteger r2 = [self randomWithMax:5] +1;
  return @[
    @(r1 > r2 ? r1 : r2),
    @(r1 < r2 ? r1 : r2)
  ];
}


- (NSUInteger)randomWithMax:(NSUInteger)maxValue {
  NSUInteger r = arc4random() % (maxValue+1); // [0,maxValue]
  return r;
}


@end
