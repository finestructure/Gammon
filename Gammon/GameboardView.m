//
//  GameboardView.m
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "GameboardView.h"

#import "Slot.h"
#import "UIColor+Gammon.h"

const CGFloat kCheckerRadius = 28;
const NSUInteger kPipsPerSection = 6;
const NSUInteger kTotalPipCount = 4*kPipsPerSection;


@interface GameboardView () {
  NSMutableArray *_targetRects;
}

@end


@implementation GameboardView


- (void)setup
{
  _targetRects = [NSMutableArray arrayWithCapacity:kTotalPipCount];
  for (int i = 0; i < kTotalPipCount; ++i) {
    _targetRects[i] = [NSNull null];
  }
  
  UIImage *patternImage = [UIImage imageNamed:@"wood_pattern"];
  self.backgroundColor = [UIColor colorWithPatternImage:patternImage];
  
  UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  gr.numberOfTapsRequired = 1;
  [self addGestureRecognizer:gr];
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

  CGFloat barWidth = 30;
  CGFloat width = (self.bounds.size.width - barWidth)/2/kPipsPerSection;
  CGFloat height = 120;
  CGColorRef pipColors[] = {
    [UIColor pipColor1].CGColor,
    [UIColor pipColor2].CGColor
  };

  for (int i = 0; i < 2*kPipsPerSection; ++i) {
    CGFloat offset = i < kPipsPerSection ? 0 : barWidth;
    { // top row
      CGRect targetRect = CGRectMake(i*width + offset, 0, width, height);
      drawPip(context, targetRect, pipColors[i % 2], NO);
      _targetRects[i] = [NSValue valueWithCGRect:targetRect];
    }
    { // bottom row
      CGRect targetRect = CGRectMake(i*width + offset, self.bounds.size.height - height, width, height);
      drawPip(context, targetRect, pipColors[(i+1) % 2], YES);
      _targetRects[kTotalPipCount - i -1] = [NSValue valueWithCGRect:targetRect];
    }
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
          x = kTotalPipCount - index;
          down = NO;
        } else {
          xOffset = 0;
          x = kTotalPipCount - index;
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


- (void)boardUpdated
{
  NSLog(@"GameboardView: board updated");
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
  NSLog(@"tapped");
  if (sender.state == UIGestureRecognizerStateEnded) {
    CGPoint p = [sender locationInView:self];
    NSUInteger index = NSNotFound;
    for (NSValue *v in _targetRects) {
      CGRect r = [v CGRectValue];
      if (CGRectContainsPoint(r, p)) {
        index = [_targetRects indexOfObject:v];
        break;
      }
    }
    if (index != NSNotFound) {
      NSLog(@"index: %d", index);
    }
  }
}


@end
