//
//  MyButton.m
//  Gammon
//
//  Created by Sven A. Schmidt on 28.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "MyButton.h"

@implementation MyButton


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initialize];
  }
  return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self initialize];
  }
  return self;
}


- (void)initialize
{
  self.borderColor = [UIColor blackColor];
  self.topColor = [UIColor darkGrayColor];
  self.bottomColor = [UIColor lightGrayColor];
}


- (void)drawRect:(CGRect)rect
{
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  UIColor *innerGlow = [UIColor colorWithWhite:1.0 alpha:0.5];
  
  // Gradient Declarations
  NSArray *gradientColors = (@[
                             (id)self.topColor.CGColor,
                             (id)self.bottomColor.CGColor
                             ]);
  
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(gradientColors), NULL);
  
  NSArray *highlightedGradientColors = (@[
                                        (id)self.bottomColor.CGColor,
                                        (id)self.topColor.CGColor
                                        ]);
  
  CGGradientRef highlightedGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(highlightedGradientColors), NULL);

  // Draw rounded rectangle bezier path
  UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: 4];
  // Use the bezier as a clipping path
  [roundedRectanglePath addClip];
  
  // Use one of the two gradients depending on the state of the button
  CGGradientRef background = self.highlighted? highlightedGradient : gradient;
  
  // Draw gradient within the path
  CGPoint p1 = CGPointMake(rect.size.width/2, 0);
  CGPoint p2 = CGPointMake(rect.size.width/2, rect.size.height);
  CGContextDrawLinearGradient(context, background, p1, p2, 0);
  
  // Draw border
  [self.borderColor setStroke];
  roundedRectanglePath.lineWidth = 2;
  [roundedRectanglePath stroke];
  
  // Draw Inner Glow
  CGRect insetRect = CGRectInset(rect, 3, 3);
  UIBezierPath *innerGlowRect = [UIBezierPath bezierPathWithRoundedRect: insetRect cornerRadius: 2.5];
  [innerGlow setStroke];
  innerGlowRect.lineWidth = 1;
  [innerGlowRect stroke];
  
  // Cleanup
  CGGradientRelease(gradient);
  CGGradientRelease(highlightedGradient);
  CGColorSpaceRelease(colorSpace);
}


- (void)setHighlighted:(BOOL)highlighted
{
  [self setNeedsDisplay];
  //  [super setHighlighted:highlighted];
}


@end
