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


@interface Game ()

@property (nonatomic) NSMutableArray *slots;
@property (assign) GameState state;
@property (nonatomic) NSArray *roll;
@property (nonatomic) NSMutableArray *moved;

@end


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
  self.state = Ended;
}


- (void)restart
{
  [self setup];
  [self next];
}


- (void)next
{
  self.roll = [self rollDice];
  self.moved = [NSMutableArray array];
  self.availableMoves = [NSMutableArray array];
  if ([self.roll[0] isEqualToNumber:self.roll[1]]) {
    for (int i = 0; i < 4; ++i) {
      [self.availableMoves addObject:self.roll[0]];
    }
  } else {
    [self.availableMoves addObjectsFromArray:self.roll];
  }

  if (self.state == Ended) {
    self.state = WhitesTurn;
  } else {
    self.state = (self.state == WhitesTurn) ? BlacksTurn : WhitesTurn;
  }
}


- (void)moveFrom:(NSUInteger)from by:(NSUInteger)by
{
  NSLog(@"moving from %d by %d", from, by);

  if (! [self movesLeft]) {
    return;
  }
  
  NSUInteger index = [self.availableMoves indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    return [obj unsignedIntegerValue] == by;
  }];
  if (index == NSNotFound) {
    // trying a move that has no corresponding die
    return;
  }
  
  // check if move is valid
#warning handle counter clockwise move!
  Slot *origin = [self.slots objectAtIndex:from];
  Slot *dest = [self.slots objectAtIndex:from+by];
  
  if ((self.state == WhitesTurn && origin.color != White) ||
      (self.state == BlacksTurn && origin.color != Black)) {
    // must move own checker
    return;
  }
  if ((dest.color == White && self.state != WhitesTurn) ||
      (dest.color == Black && self.state != BlacksTurn)) {
    if (dest.count > 1) {
      // dest blocked
      return;
    }
  }
  
  // perform valid move
  origin.count -= 1;
  dest.count += 1;
  if (dest.color == Free) {
    dest.color = origin.color;
  }
  
  NSLog(@"moved from %d to %d", from, from + by);
  [self.moved addObject:@(by)];
  [self.availableMoves removeObjectAtIndex:index];
  
  if ([self.delegate respondsToSelector:@selector(boardUpdated)]) {
    [self.delegate boardUpdated];
  }
}


- (BOOL)movesLeft
{
  return [self.availableMoves count] > 0;
}


- (NSArray *)rollDice
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
