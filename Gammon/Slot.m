//
//  Pip.m
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "Slot.h"

@implementation Slot


- (id)init
{
  return [self initWithColor:Free];
}


- (id)initWithColor:(CheckerColor)color
{
  self = [super init];
  if (self) {
    self.index = 0;
    self.color = color;
    self.count = 0;
  }
  return self;
}


- (void)setColorObject:(NSNumber *)color
{
  NSUInteger value = [color unsignedIntegerValue];
  if (value >= First && value <= Last ) {
    self.color = value;
  }
}


- (NSString *)description
{
  return [NSString stringWithFormat:@"Slot %d, %@ (%d)", self.index, (self.color == Free ? @"Free" : (self.color == White ? @"White" : @"Black")), self.count];
}


@end
