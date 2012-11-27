//
//  GameboardView.m
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "GameboardView.h"

#import "Game.h"
#import "Slot.h"
#import "UIColor+Gammon.h"

const CGFloat kCheckerRadius = 28;


@implementation GameboardView


- (void)setup
{
  UIImage *patternImage = [UIImage imageNamed:@"wood_pattern"];
  self.backgroundColor = [UIColor colorWithPatternImage:patternImage];
}


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setup];
  }
  return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self setup];
  }
  return self;
}


- (void)drawRect:(CGRect)rect
{  
  [self drawBoard];
}


- (void)drawBoard
{
  CGContextRef context = UIGraphicsGetCurrentContext();

  int pipsPerSection = 6;
  CGFloat barWidth = 30;
  CGFloat width = (self.bounds.size.width - barWidth)/2/pipsPerSection;
  CGFloat height = 120;
  CGColorRef pipColors[] = {
    [UIColor pipColor1].CGColor,
    [UIColor pipColor2].CGColor
  };

  for (int i = 0; i < 2*pipsPerSection; ++i) {
    CGFloat offset = i < pipsPerSection ? 0 : barWidth;
    drawPip(context, CGRectMake(i*width + offset, 0, width, height), pipColors[i % 2], NO);
    drawPip(context, CGRectMake(i*width + offset, self.bounds.size.height - height, width, height), pipColors[(i+1) % 2], YES);
  }
  
  if (self.game) {
    for (Slot *s in self.game.slots) {
      if (s.count > 0) {
        NSUInteger index = [self.game.slots indexOfObject:s];
        UIColor *color = s.color == White ? [UIColor whiteColor] : [UIColor blackColor];
        CGFloat xOffset;
        NSUInteger x;
        BOOL down;
        if (index <= 6) {
          xOffset = 0;
          x = index -1;
          down = YES;
        } else if (index <= 12) {
          xOffset = barWidth;
          x = index -1;
          down = YES;
        } else if (index <= 18) {
          xOffset = barWidth;
          x = 4*pipsPerSection - index;
          down = NO;
        } else {
          xOffset = 0;
          x = 4*pipsPerSection - index;
          down = NO;
        }
        for (int y = 0; y < s.count; ++y) {
          CGFloat yPos = down ? y*kCheckerRadius : self.bounds.size.height - (y +1)*kCheckerRadius;
          CGRect rect = CGRectMake(x*width + xOffset + (width-kCheckerRadius)/2, yPos, kCheckerRadius, kCheckerRadius);
          drawChecker(context, rect, color.CGColor);
        }
      }
    }
  }
}


void drawChecker(CGContextRef ctx, CGRect rect, CGColorRef color)
{
  CGContextSetFillColorWithColor(ctx, color);
  CGContextFillEllipseInRect(ctx, rect);
}


void drawPip(CGContextRef ctx, CGRect rect, CGColorRef color, BOOL up)
{
  CGContextBeginPath(ctx);
  if (up) {
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
  } else {
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
  }
  CGContextClosePath(ctx);
  
  CGContextSetFillColorWithColor(ctx, color);
  CGContextFillPath(ctx);
}


@end
