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
@property (nonatomic) NSDictionary *bar;
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
  // We keep 24 slots in an array describing the layout of the complete board.
  // Slot 0 is unused, we use a 1-based index to be compatible with typical backgammon move notation
  NSMutableArray *slots = [NSMutableArray arrayWithCapacity:kSlotCount+1];
  for (NSUInteger i = 0; i < kSlotCount+1; ++i) {
    Slot *s = [[Slot alloc] init];
    s.index = i;
    [slots addObject:s];
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
  
  // Set up bar slots, we need a white and a black one
  self.bar = @{@(White) : [[Slot alloc] init], @(Black) : [[Slot alloc] init]};
  
  self.state = Ended;
  
  if ([self.delegate respondsToSelector:@selector(boardUpdated)]) {
    [self.delegate boardUpdated];
  }
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


- (BOOL)moveFrom:(NSUInteger)from by:(NSUInteger)by
{
  NSLog(@"moving from %d by %d", from, by);

  if (! [self movesLeft]) {
    NSLog(@"no more moves!");
    return NO;
  }

  if (self.state == Ended) {
    NSLog(@"game over!");
    return NO;
  }

  NSUInteger index = [self.availableMoves indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    return [obj unsignedIntegerValue] == by;
  }];
  if (index == NSNotFound) {
    // trying a move that has no corresponding die
    NSLog(@"move not available!");
    return NO;
  }
  
  // check if move is valid
  Slot *origin = [self.slots objectAtIndex:from];
  Slot *dest;
  if (self.state == WhitesTurn) {
    dest = [self.slots objectAtIndex:from + by];
  } else {
    // black moves counter clockwise
    dest = [self.slots objectAtIndex:from - by];
  }
  
  if ((self.state == WhitesTurn && origin.color != White) ||
      (self.state == BlacksTurn && origin.color != Black)) {
    // must move own checker
    NSLog(@"cannot move opponents checker!");
    return NO;
  }
  BOOL hit = NO;
  if ((dest.color == White && self.state != WhitesTurn) ||
      (dest.color == Black && self.state != BlacksTurn)) {
    if (dest.count > 1) {
      // dest blocked
      NSLog(@"destination blocked!");
      return NO;
    } else if (dest.count == 1) {
      hit = YES;
    }
  }
  
  if (hit) {
    // we're hitting a blot, put it on the bar
    Slot *bar = self.bar[@(dest.color)];
    bar.count += 1;
  } else {
    // perform normal move
    dest.count += 1;
  }
  dest.color = origin.color;
  origin.count -= 1;
  if (origin.count == 0) {
    origin.color = Free;
  }
  
  // update dice tracking
  [self.moved addObject:@(by)];
  [self.availableMoves removeObjectAtIndex:index];
  
  // notify delegate
  if ([self.delegate respondsToSelector:@selector(boardUpdated)]) {
    [self.delegate boardUpdated];
  }
  
  return YES;
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


- (Slot *)whiteBar
{
  return self.bar[@(White)];
}


- (Slot *)blackBar
{
  return self.bar[@(Black)];
}


@end
