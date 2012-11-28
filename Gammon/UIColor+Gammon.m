//
//  UIColor+Gammon.m
//  Gammon
//
//  Created by Sven A. Schmidt on 27.11.12.
//  Copyright (c) 2012 Sven A. Schmidt. All rights reserved.
//

#import "UIColor+Gammon.h"

@implementation UIColor (Gammon)


+ (UIColor *)darkBrownColor
{
  return [UIColor colorWithRed:0.420 green:0.200 blue:0.063 alpha:1.000];
}


+ (UIColor *)lightBrownColor
{
  return [UIColor colorWithRed:0.980 green:0.890 blue:0.682 alpha:1.000];
}


+ (UIColor *)middleBrownColor
{
  return [UIColor colorWithRed:0.694 green:0.424 blue:0.188 alpha:1.000];
}


+ (UIColor *)mossColor
{
  return [UIColor colorWithRed:0.000 green:0.502 blue:0.251 alpha:1.000];
}


+ (UIColor *)pipColor1
{
  return [UIColor mossColor];
}


+ (UIColor *)pipColor2
{
  return [UIColor colorWithRed:0.600 green:0.400 blue:0.200 alpha:1.000];
}


@end
