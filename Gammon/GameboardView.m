//
//  GameboardView.m
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "GameboardView.h"

#import "UIColor+Gammon.h"

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
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  int pipsPerRow = 12;
  CGFloat width = (int)self.bounds.size.width/pipsPerRow;
  CGFloat height = 120;
  CGColorRef pipColors[] = {
    [UIColor pipColor1].CGColor,
    [UIColor pipColor2].CGColor
  };
  for (int i = 0; i < pipsPerRow; ++i) {
    drawPip(context, CGRectMake(i*width, 0, width, height), pipColors[i % 2], NO);
    drawPip(context, CGRectMake(i*width, self.bounds.size.height - height, width, height), pipColors[(i+1) % 2], YES);
  }
}


void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint,
                   CGColorRef color) {
  CGContextSaveGState(context);
  CGContextSetLineCap(context, kCGLineCapSquare);
  CGContextSetStrokeColorWithColor(context, color);
  CGContextSetLineWidth(context, 1.0);
  CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
  CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
  CGContextStrokePath(context);
  CGContextRestoreGState(context);
}


void drawPip(CGContextRef ctx, CGRect rect, CGColorRef color, BOOL up) {
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
