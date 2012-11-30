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
  White
} CheckerColor;


@interface Slot : NSObject

@property (assign) CheckerColor color;
@property (assign) NSUInteger count;

@end
