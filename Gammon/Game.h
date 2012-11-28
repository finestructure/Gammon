//
//  Game.h
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum GameState {
  Ended = 0,
  WhitesTurn,
  BlacksTurn
} GameState;


@interface Game : NSObject

@property (readonly, nonatomic) NSArray *slots;
@property (readonly, assign) GameState state;
@property (readonly, nonatomic) NSArray *roll;

- (void)start;
- (void)next;

@end
