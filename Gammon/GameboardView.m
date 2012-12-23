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

const CGFloat kBarWidth = 30;
const CGFloat kCheckerRadius = 24;
const NSUInteger kPipsPerSection = 6;
const NSUInteger kTotalPipCount = 4*kPipsPerSection;
const CGFloat kPipHeight = 120;


@interface GameboardView () {
  NSMutableArray *_targetRects;
}

@property (readonly) CGSize boardSize;
@property (readonly) CGFloat pipWidth;

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


- (CGSize)boardSize
{
  return self.bounds.size;
}


- (CGFloat)pipWidth
{
  return (self.boardSize.width - kBarWidth)/2/kPipsPerSection;
}


- (void)drawRect:(CGRect)rect
{  
  CGContextRef context = UIGraphicsGetCurrentContext();

  [self drawBar:context];
  [self drawPips:context];
  [self drawCheckers:context];
}


- (void)drawBar:(CGContextRef)context
{
  CGColorRef color = [UIColor darkBrownColor].CGColor;
  CGContextSetFillColorWithColor(context, color);
  CGFloat barX = self.boardSize.width/2 - kBarWidth/2;
  CGRect rect = CGRectMake(barX, 0, kBarWidth, self.boardSize.height);
  CGContextFillRect(context, rect);
}


- (void)drawPips:(CGContextRef)context
{
  CGColorRef pipColors[] = {
    [UIColor pipColor1].CGColor,
    [UIColor pipColor2].CGColor
  };
  
  for (int i = 0; i < kTotalPipCount; ++i) {
    CGRect pipRect = [self pipRectAtIndex:i];
    BOOL topRow = (i < kTotalPipCount/2);
    drawPip(context, pipRect, pipColors[i % 2], topRow);
    _targetRects[i] = [NSValue valueWithCGRect:pipRect];
  }
}


- (CGRect)pipRectAtIndex:(NSUInteger)index
{
  BOOL topRow = (index < kTotalPipCount/2);
  BOOL rightSide = (index >= kPipsPerSection && index < 3*kPipsPerSection);
  CGFloat y = topRow ? 0 : self.boardSize.height - kPipHeight;
  CGFloat x = topRow ? index*self.pipWidth : self.boardSize.width - (index - kTotalPipCount/2 +1)*self.pipWidth;
  if (topRow && rightSide) {
    x += kBarWidth;
  } else if (!topRow && !rightSide) {
    x -= kBarWidth;
  }
  return CGRectMake(x, y, self.pipWidth, kPipHeight);
}


- (void)drawCheckers:(CGContextRef)context
{
  if (self.game == nil) {
    return;
  }
  
  { // draw checkers on regular slots
    for (Slot *s in self.game.slots) {
      if (s.count == 0) {
        continue;
      }
      
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
        xOffset = kBarWidth;
        x = index -1;
        down = YES;
      } else if (index <= 18) {
        xOffset = kBarWidth;
        x = kTotalPipCount - index;
        down = NO;
      } else {
        xOffset = 0;
        x = kTotalPipCount - index;
        down = NO;
      }
      CGFloat xCenter = x*self.pipWidth + xOffset + self.pipWidth/2;
      [self drawStack:context count:s.count xCenter:xCenter down:down color:color];
    }
  }
  
  { // draw checkers on bar (top: white, bottom: black)
    [@[self.game.whiteBar, self.game.blackBar] enumerateObjectsUsingBlock:^(Slot *s, NSUInteger idx, BOOL *stop) {
      CGFloat barCenter = self.boardSize.width/2;
      UIColor *color = s.color == White ? [UIColor whiteColor] : [UIColor blackColor];
      BOOL down = (s.color == White);
      [self drawStack:context count:s.count xCenter:barCenter down:down color:color];
    }];
  }
}


- (void)drawStack:(CGContextRef)context count:(NSUInteger)count xCenter:(CGFloat)xCenter down:(BOOL)down color:(UIColor *)color
{
  for (int y = 0; y < count; ++y) {
    CGFloat yPos = down ? y*kCheckerRadius : self.boardSize.height - (y+1)*kCheckerRadius;
    CGRect rect = CGRectMake(xCenter - kCheckerRadius/2, yPos, kCheckerRadius, kCheckerRadius);
    drawChecker(context, rect, color.CGColor);
  }
}


- (void)boardUpdated
{
  NSLog(@"GameboardView: board updated");
  [self setNeedsDisplay];
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
  if (sender.state == UIGestureRecognizerStateEnded) {
    CGPoint p = [sender locationInView:self];
    { // has the bar been tapped?
      
    }
    
    { // has a pip been tapped?
      NSUInteger index = NSNotFound;
      for (NSValue *v in _targetRects) {
        CGRect r = [v CGRectValue];
        if (CGRectContainsPoint(r, p)) {
          index = [_targetRects indexOfObject:v];
          break;
        }
      }
      if (index != NSNotFound) {
        if ([self.delegate respondsToSelector:@selector(pipTapped:)]) {
          NSUInteger oneBasedIndex = index +1;
          [self.delegate pipTapped:oneBasedIndex];
        }
      }
    }
  }
}


#pragma mark - Draw helpers


void drawChecker(CGContextRef ctx, CGRect rect, CGColorRef color)
{
  CGContextSetFillColorWithColor(ctx, color);
  CGContextFillEllipseInRect(ctx, rect);
}


void drawPip(CGContextRef ctx, CGRect rect, CGColorRef color, BOOL topRow)
{
  CGContextBeginPath(ctx);
  if (topRow) {
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
  } else {
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
  }
  CGContextClosePath(ctx);
  
  CGContextSetFillColorWithColor(ctx, color);
  CGContextFillPath(ctx);
}


@end
