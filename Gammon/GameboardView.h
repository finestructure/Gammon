//
//  GameboardView.h
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Game.h"

@interface GameboardView : UIView<GameDelegate>

@property (nonatomic) Game *game;

@end
