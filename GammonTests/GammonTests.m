//
//  GammonTests.m
//  GammonTests
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "Game.h"
#import "Slot.h"


#define AssertSlot(_index, _color, _count) {\
Slot *s = game.slots[_index]; \
STAssertNotNil(s, nil); \
STAssertEquals(s.color, _color, @"slot %d color should be %@", _index, (_color == Free ? @"Free" : (_color == White ? @"White" : @"Black"))); \
STAssertEquals(s.count, (NSUInteger)_count, @"slot %d count shoud be %d (actual: %d)", _index, _count, s.count); \
}


@interface GammonTests : SenTestCase {
  Game *game;
}

@end


@interface Game (Test)

@property (nonatomic) NSArray *fixedRoll;

- (NSArray *)rollDice;

@end

@implementation Game (Test)

- (NSArray *)fixedRoll
{
  static NSMutableArray *roll;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    roll = [@[@0, @0] mutableCopy];
  });
  return roll;
}


- (void)setFixedRoll:(NSArray *)fixedRoll
{
  [(NSMutableArray *)self.fixedRoll replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withObjects:fixedRoll];
}


- (NSArray *)rollDice
{
  return [self fixedRoll];
}

@end


@implementation GammonTests

- (void)setUp
{
  [super setUp];
    
  game = [[Game alloc] init];
}


- (void)tearDown
{
  [super tearDown];
}


- (void)test_issue_02
{
  game.fixedRoll = @[@1, @1];
  [game restart];
  
  STAssertEqualObjects(game.roll, (@[@1, @1]), nil);
  STAssertEquals(game.state, WhitesTurn, nil);
  BOOL moved = [game moveFrom:1 by:1];
  STAssertTrue(moved, nil);
  
  AssertSlot(1, White, 1);
  AssertSlot(2, White, 1);
  AssertSlot(3, Free, 0);
 
  moved = [game moveFrom:2 by:1];
  STAssertTrue(moved, nil);

  AssertSlot(1, White, 1);
  AssertSlot(2, Free, 0);
  AssertSlot(3, White, 1);

  moved = [game moveFrom:3 by:1];
  STAssertTrue(moved, nil);
  moved = [game moveFrom:4 by:1];
  STAssertTrue(moved, nil);
  
  AssertSlot(1, White, 1);
  AssertSlot(2, Free, 0);
  AssertSlot(3, Free, 0);
  AssertSlot(4, Free, 0);
  AssertSlot(5, White, 1);
  AssertSlot(6, Black, 5);
  
  game.fixedRoll = @[@2, @1];
  [game next];
  STAssertEqualObjects(game.roll, (@[@2, @1]), nil);
  STAssertEquals(game.state, BlacksTurn, nil);
  moved = [game moveFrom:6 by:2];
  STAssertTrue(moved, nil);
  moved = [game moveFrom:4 by:1];
  STAssertTrue(moved, nil);

  AssertSlot(1, White, 1);
  AssertSlot(2, Free, 0);
  AssertSlot(3, Black, 1);
  AssertSlot(4, Free, 0);
  AssertSlot(5, White, 1);
  AssertSlot(6, Black, 4);
}

@end
