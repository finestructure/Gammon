//
//  Game.h
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Game : NSObject

@property (nonatomic) NSArray *slots;

- (NSArray *)roll;

@end
