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
  self = [super init];
  if (self) {
    self.color = Free;
  }
  return self;
}


- (NSString *)description
{
  return [NSString stringWithFormat:@"Slot %d, %@ (%d)", self.index, (self.color == Free ? @"Free" : (self.color == White ? @"White" : @"Black")), self.count];
}


@end
