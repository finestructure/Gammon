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
    // Initialization code
  }
  return self;
}


- (void)drawRect:(CGRect)rect
{
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  UIColor *darkBrown = [UIColor colorWithRed:0.420 green:0.200 blue:0.063 alpha:1.000];
  UIColor *middleBrown = [UIColor colorWithRed:0.694 green:0.424 blue:0.188 alpha:1.000];
  UIColor *lightBrown = [UIColor colorWithRed:0.980 green:0.890 blue:0.682 alpha:1.000];
  
  UIColor *borderColor = darkBrown;
  UIColor *topColor = lightBrown;
  UIColor *bottomColor = middleBrown;
  UIColor *innerGlow = [UIColor colorWithWhite:1.0 alpha:0.5];
  
  // Gradient Declarations
  NSArray *gradientColors = (@[
                             (id)topColor.CGColor,
                             (id)bottomColor.CGColor
                             ]);
  
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(gradientColors), NULL);
  
  NSArray *highlightedGradientColors = (@[
                                        (id)bottomColor.CGColor,
                                        (id)topColor.CGColor
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
  [borderColor setStroke];
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
  [super setHighlighted:highlighted];
}


@end
