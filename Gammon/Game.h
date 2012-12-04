//
//  Game.h
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GameDelegate <NSObject>

- (void)boardUpdated;

@end


typedef enum GameState {
  Ended = 0,
  WhitesTurn,
  BlacksTurn
} GameState;


@interface Game : NSObject

@property (weak, nonatomic) id<GameDelegate> delegate;
@property (readonly, nonatomic) NSArray *slots;
@property (readonly, assign) GameState state;
@property (readonly, nonatomic) NSArray *roll;
@property (nonatomic) NSMutableArray *availableMoves;

- (void)restart;
- (void)next;

- (BOOL)moveFrom:(NSUInteger)from by:(NSUInteger)by;
- (BOOL)movesLeft;

@end
