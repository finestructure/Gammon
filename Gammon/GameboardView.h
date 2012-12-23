//
//  GameboardView.h
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Game.h"


@protocol BoardDelegate <NSObject>

- (void)pipTapped:(NSUInteger)index;
- (void)barTapped;

@end


@interface GameboardView : UIView<GameDelegate>

@property (weak, nonatomic) id<BoardDelegate> delegate;
@property (nonatomic) Game *game;

@end
