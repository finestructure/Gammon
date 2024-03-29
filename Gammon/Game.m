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

@property (nonatomic) NSUndoManager *undoManager;

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
  self.undoManager = [[NSUndoManager alloc] init];
  
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
  self.bar = @{@(White) : [[Slot alloc] initWithColor:White], @(Black) : [[Slot alloc] initWithColor:Black]};
  
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
  [self.undoManager removeAllActions]; // don't allow undo after new roll
  self.moved = [NSMutableArray array];
  self.availableMoves = [NSMutableArray array];
  if ([self.roll[0] isEqualToNumber:self.roll[1]]) {
    // add four values in case of a double
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


- (void)swapDice
{
  self.roll = @[self.roll[1], self.roll[0]];
  self.availableMoves = [[[self.availableMoves reverseObjectEnumerator] allObjects] mutableCopy];
}


- (void)undo
{
  [self.undoManager undo];
  
  // notify delegate
  if ([self.delegate respondsToSelector:@selector(boardUpdated)]) {
    [self.delegate boardUpdated];
  }
  
  NSLog(@"\n%@", self);
}


- (BOOL)moveFrom:(NSUInteger)from by:(NSUInteger)by
{
  [self.undoManager beginUndoGrouping];
  
  NSLog(@"moving from %d by %d", from, by);
  NSAssert((from >= 0 && from <= 24), @"from must be within [0, 24], was: %d", from);

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
  
  {
    Slot *bar = (self.state == WhitesTurn) ? self.whiteBar : self.blackBar;
    if (bar.count > 0 && from != 0) {
      NSLog(@"must move in from the bar first");
      return NO;
    }
  }
  
  // check if move is valid
  Slot *origin;
  Slot *dest;
  if (from == 0) {
    // moving in from the bar
    if (self.state == WhitesTurn) {
      NSUInteger destIndex = by;
      NSAssert((destIndex >= 1 && destIndex <= 6), @"dest index must be within [1, 6] when moving in white from the bar, was: %d", destIndex);
      origin = self.whiteBar;
      dest = [self.slots objectAtIndex:destIndex];
    } else {
      NSUInteger destIndex = 25 - by;
      NSAssert((destIndex >= 19 && destIndex <= 24), @"dest index must be within [19, 24] when moving in black from the bar, was: %d", destIndex);
      origin = self.blackBar;
      dest = [self.slots objectAtIndex:destIndex];
    }
  } else {
    origin = [self.slots objectAtIndex:from];
    if (self.state == WhitesTurn) {
      NSUInteger destIndex = from + by;
      NSAssert((destIndex >= 1 && destIndex <= 24), @"from + by must be within [1, 24], was: %d", destIndex);
      dest = [self.slots objectAtIndex:destIndex];
    } else {
      // black moves counter clockwise
      NSUInteger destIndex = from - by;
      NSAssert((destIndex >= 1 && destIndex <= 24), @"from - by must be within [1, 24], was: %d", destIndex);
      dest = [self.slots objectAtIndex:destIndex];
    }
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
    [[self.undoManager prepareWithInvocationTarget:bar] setCount:bar.count];
    bar.count += 1;
  } else {
    // perform normal move
    [[self.undoManager prepareWithInvocationTarget:dest] setCount:dest.count];
    dest.count += 1;
  }
  [[self.undoManager prepareWithInvocationTarget:dest] setColorObject:@(dest.color)];
  dest.color = origin.color;
  [[self.undoManager prepareWithInvocationTarget:origin] setCount:origin.count];
  origin.count -= 1;
  if (origin.count == 0 && from != 0) { // don't reset color on bar slots
    [[self.undoManager prepareWithInvocationTarget:origin] setColorObject:@(origin.color)];
    origin.color = Free;
  }
  
  // update dice tracking
  [[self.undoManager prepareWithInvocationTarget:self.moved] removeLastObject];
  [self.moved addObject:@(by)];
  [[self.undoManager prepareWithInvocationTarget:self.availableMoves] insertObject:[self.availableMoves objectAtIndex:index] atIndex:index];
  [self.availableMoves removeObjectAtIndex:index];
  
  // notify delegate
  if ([self.delegate respondsToSelector:@selector(boardUpdated)]) {
    [self.delegate boardUpdated];
  }
  
  NSLog(@"\n%@", self);
  
  [self.undoManager endUndoGrouping];
  
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
    @(MAX(r1, r2)),
    @(MIN(r1, r2))
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


- (NSString *)description
{
  NSMutableArray *lines = [NSMutableArray array];
  [lines addObject:@" 1  2  3  4  5  6     7  8  9  10 11 12"];

  [lines addObjectsFromArray:[self linesTopRow:YES]];
  [lines addObjectsFromArray:@[@"", @""]];
  [lines addObjectsFromArray:[[[self linesTopRow:NO] reverseObjectEnumerator] allObjects]];
    
  [lines addObject:@" 24 23 22 21 20 19    18 17 16 15 14 13"];
  
  NSDictionary *stateDesc = @{@(Ended): @"--", @(WhitesTurn) : @"White", @(BlacksTurn) : @"Black"};
  [lines addObject:[NSString stringWithFormat:@"Turn: %@", stateDesc[@(self.state)]]];
  [lines addObject:[NSString stringWithFormat:@"Roll: %@", self.roll]];
  [lines addObject:[NSString stringWithFormat:@"Left: %@", self.availableMoves]];
  
  return [lines componentsJoinedByString:@"\n"];
}


- (NSArray *)linesTopRow:(BOOL)topRow
{  
  NSMutableArray *lines = [NSMutableArray array];
  BOOL done = NO;
  NSUInteger row = 1;
  while (! done) {
    NSMutableString *line = [NSMutableString stringWithString:@""];
    BOOL stackFound = NO;
    for (int i = 1; i <= 12; ++i) {
      if (i == 7) {
        // add bar
        Slot *bar = topRow ? self.whiteBar : self.blackBar;
        NSString *symbol = @" ";
        if (bar.count >= row) {
          symbol = (bar.color == White ? @"O" : @"X");
        }
        [line appendString:[NSString stringWithFormat:@" %@ ", symbol]];
      }
      NSUInteger index = topRow ? i : 25 - i;
      
      Slot *s = self.slots[index];
      NSString *symbol = @" ";
      if (s.count >= row) {
        symbol = (s.color == White ? @"O" : @"X");
        stackFound = YES;
      }
      [line appendString:[NSString stringWithFormat:@" %@ ", symbol]];
    }
    if (stackFound) {
      [lines addObject:line];
    } else {
      done = YES;
    }
    ++row;
  }
  return lines;
}


@end
