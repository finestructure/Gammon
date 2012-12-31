//
//  Pip.h
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum CheckerColor {
  Free = 0,
  Black,
  White,
  // keep track or range
  First = Free,
  Last = White
} CheckerColor;


@interface Slot : NSObject

@property (assign) NSUInteger index;
@property (assign) CheckerColor color;
@property (assign) NSUInteger count;

- (id)initWithColor:(CheckerColor)color;

// convenience method to support undo manager
- (void)setColorObject:(NSNumber *)color;

@end
