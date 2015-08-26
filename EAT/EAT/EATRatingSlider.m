//
//  EATRatingSlider.m
//  EAT
//
//  Created by Emlyn Murphy on 2/2/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATRatingSlider.h"
#import "EATConstants.h"

const CGFloat EATSliderOriginalWidth = 281;
const CGFloat EATSliderOriginalHeight = 94;
const CGRect  EATSliderBeforeRect = {{122, 1},  {38, 42}};
const CGRect  EATSliderAfterRect  = {{122, 44}, {38, 43}};

@interface EATRatingSlider ()

@property (nonatomic) float beforeSliderXOffset;
@property (nonatomic) float afterSliderXOffset;
@property (nonatomic) CGPoint beginTouchPoint;
@property (nonatomic) BOOL touchedBeforeSlider;
@property (nonatomic) BOOL touchedAfterlider;

@end

@implementation EATRatingSlider

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)setCompact:(BOOL)compact {
    _compact = compact;
    self.userInteractionEnabled = !compact;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint unscaledTouchPoint = [touch locationInView:self];
    float scaleX =  EATSliderOriginalWidth / self.bounds.size.width;
    self.beginTouchPoint = CGPointMake(unscaledTouchPoint.x * scaleX, unscaledTouchPoint.y);
    
    if (CGRectContainsPoint(CGRectOffset(EATSliderBeforeRect, self.beforeSliderXOffset, 0), self.beginTouchPoint)) {
        self.touchedBeforeSlider = YES;
        self.touchedAfterlider = NO;
        return YES;
    }
    
    if (CGRectContainsPoint(CGRectOffset(EATSliderAfterRect, self.afterSliderXOffset, 0), self.beginTouchPoint)) {
        self.touchedBeforeSlider = NO;
        self.touchedAfterlider = YES;
        return YES;
    }
    
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    float scaleX =  EATSliderOriginalWidth / self.bounds.size.width;
    
    if (self.touchedBeforeSlider) {
        self.beforeSliderXOffset = lastPoint.x * scaleX - EATSliderBeforeRect.origin.x - EATSliderBeforeRect.size.width / 2;
        
        if (self.beforeSliderXOffset < -120) {
            self.beforeSliderXOffset = -120;
        }
        
        if (self.beforeSliderXOffset > 120) {
            self.beforeSliderXOffset = 120;
        }
        
        [self setNeedsDisplay];
    } else if (self.touchedAfterlider) {
        self.afterSliderXOffset = lastPoint.x * scaleX - EATSliderAfterRect.origin.x - EATSliderAfterRect.size.width / 2;
        
        if (self.afterSliderXOffset < -120) {
            self.afterSliderXOffset = -120;
        }
        
        if (self.afterSliderXOffset > 120) {
            self.afterSliderXOffset = 120;
        }
        
        [self setNeedsDisplay];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    float scaleX = self.bounds.size.width / EATSliderOriginalWidth;
    float offsetY = 0.0;
    
    if (self.compact) {
        offsetY = -30;
    }
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor *strokeColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1];
    UIColor *color3 = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    UIColor *color5 = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
//    UIColor *sliderLabelColor = [UIColor colorWithRed:0.427 green:0.427 blue:0.447 alpha:1];
	UIColor *sliderLabelColor = [UIColor whiteColor];
    
    
    //// Gradient Declarations
    NSArray *redToGreenColors = @[(id)EATRedColor.CGColor,
                                  (id)EATYellowColor.CGColor,
                                  (id)EATYellowColor.CGColor,
                                  (id)EATGreenColor.CGColor,
                                  (id)EATGreenColor.CGColor,
                                  (id)EATYellowColor.CGColor,
                                  (id)EATYellowColor.CGColor,
                                  (id)EATRedColor.CGColor];
    
    CGFloat redToGreenLocations[] = { 0, 0.15, 0.25, 0.35, 0.65, 0.75, 0.85, 1 };
    CGGradientRef redToGreen = CGGradientCreateWithColors(colorSpace, (CFArrayRef)redToGreenColors, redToGreenLocations);
    
    //// Shadow Declarations
    UIColor *shadow = [[UIColor blackColor] colorWithAlphaComponent:0.18];
    CGSize shadowOffset = CGSizeMake(0.1, 3.1);
    CGFloat shadowBlurRadius = 5;
    UIColor *shadow2 = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    CGSize shadow2Offset = CGSizeMake(0.1, -0.1);
    CGFloat shadow2BlurRadius = 5;
    
    //// Abstracted Attributes
    NSString *text1Content = @"1";
    NSString *text2Content = @"2";
    NSString *text3Content = @"3";
    NSString *text4Content = @"4";
    NSString *text5Content = @"5";
    NSString *text6Content = @"6";
    NSString *text7Content = @"7";
    NSString *textAContent = @"After";
    NSString *textBContent = @"Before";
    
    //// Text Attributes
    NSMutableParagraphStyle *centerParagraphStyle = [NSMutableParagraphStyle new];
    [centerParagraphStyle setAlignment:NSTextAlignmentCenter];
    
    //// Labels
    if (self.compact == NO) {
        NSDictionary *labelAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12],
                                           NSForegroundColorAttributeName: color3,
                                           NSParagraphStyleAttributeName: centerParagraphStyle };
        
        //// Text 7 Drawing
        CGRect text7Rect = CGRectMake(253 * scaleX, 57 + 12, 15 * scaleX, 16);
        [color3 setFill];
        [text7Content drawInRect:text7Rect withAttributes:labelAttributes];
        
        
        //// Text 6 Drawing
        CGRect text6Rect = CGRectMake(213 * scaleX, 57 + 12, 15 * scaleX, 16);
        [color3 setFill];
        [text6Content drawInRect:text6Rect withAttributes:labelAttributes];
        
        
        //// Text 5 Drawing
        CGRect text5Rect = CGRectMake(173 * scaleX, 57 + 12, 15 * scaleX, 16);
        [color3 setFill];
        [text5Content drawInRect:text5Rect withAttributes:labelAttributes];
        
        
        //// Text 4 Drawing
        CGRect text4Rect = CGRectMake(133 * scaleX, 57 + 12, 15 * scaleX, 16);
        [color3 setFill];
        [text4Content drawInRect:text4Rect withAttributes:labelAttributes];
        
        
        //// Text 3 Drawing
        CGRect text3Rect = CGRectMake(93 * scaleX, 57 + 12, 15 * scaleX, 16);
        [color3 setFill];
        [text3Content drawInRect:text3Rect withAttributes:labelAttributes];
        
        
        //// Text 2 Drawing
        CGRect text2Rect = CGRectMake(53 * scaleX, 57 + 12, 15 * scaleX, 16);
        [color3 setFill];
        [text2Content drawInRect:text2Rect withAttributes:labelAttributes];
        
        
        //// Text 1 Drawing
        CGRect text1Rect = CGRectMake(13 * scaleX, 57 + 12, 15 * scaleX, 16);
        [color3 setFill];
        [text1Content drawInRect:text1Rect withAttributes:labelAttributes];
    }
    
    
    //// Background Gradient Drawing
    UIBezierPath *backgroundGradientPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(11 * scaleX, 36.5 + offsetY, (EATSliderOriginalWidth - 23) * scaleX, 31) cornerRadius:15];
    CGContextSaveGState(context);
    [backgroundGradientPath addClip];
    CGContextDrawLinearGradient(context, redToGreen, CGPointMake(11 * scaleX, 44 + offsetY), CGPointMake((EATSliderOriginalWidth - 12) * scaleX, 44 + offsetY), 0);
    CGContextRestoreGState(context);
    
    ////// Background Gradient Inner Shadow
    CGRect backgroundGradientBorderRect = CGRectInset([backgroundGradientPath bounds], -shadow2BlurRadius, -shadow2BlurRadius);
    backgroundGradientBorderRect = CGRectOffset(backgroundGradientBorderRect, -shadow2Offset.width, -shadow2Offset.height);
    backgroundGradientBorderRect = CGRectInset(CGRectUnion(backgroundGradientBorderRect, [backgroundGradientPath bounds]), -1, -1);
    
    UIBezierPath *backgroundGradientNegativePath = [UIBezierPath bezierPathWithRect:backgroundGradientBorderRect];
    [backgroundGradientNegativePath appendPath:backgroundGradientPath];
    backgroundGradientNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadow2Offset.width + round(backgroundGradientBorderRect.size.width);
        CGFloat yOffset = shadow2Offset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadow2BlurRadius,
                                    shadow2.CGColor);
        
        [backgroundGradientPath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(backgroundGradientBorderRect.size.width), 0);
        [backgroundGradientNegativePath applyTransform:transform];
        [[UIColor grayColor] setFill];
        [backgroundGradientNegativePath fill];
    }
    CGContextRestoreGState(context);
    
    [strokeColor setStroke];
    backgroundGradientPath.lineWidth = 1;
    [backgroundGradientPath stroke];
    
    NSDictionary *sliderBLabelAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:9],
                                             NSForegroundColorAttributeName: sliderLabelColor,
                                             NSParagraphStyleAttributeName: centerParagraphStyle };
    NSDictionary *sliderALabelAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:9],
                                             NSForegroundColorAttributeName: sliderLabelColor,
                                             NSParagraphStyleAttributeName: centerParagraphStyle };
    
    
    float beforeSliderX = (141 + self.beforeSliderXOffset) * scaleX;
    float beforeSliderOriginalX = 141;
    
    //// After Slider Group
    if (self.compact == NO) {
        //// Before Slider Drawing
        UIBezierPath *beforeSliderPath = [UIBezierPath bezierPath];
        [beforeSliderPath moveToPoint:CGPointMake(beforeSliderX, 44 + 8)];
        [beforeSliderPath addCurveToPoint:CGPointMake(beforeSliderX + (159.34 - beforeSliderOriginalX), 20.04 + 8) controlPoint1:CGPointMake(beforeSliderX, 44 + 8) controlPoint2:CGPointMake(beforeSliderX + (159.03 - beforeSliderOriginalX), 25.88 + 8)];
        [beforeSliderPath addCurveToPoint:CGPointMake(beforeSliderX + (153.97 - beforeSliderOriginalX), 7.17 + 8) controlPoint1:CGPointMake(beforeSliderX + (159.63 - beforeSliderOriginalX), 14.54 + 8) controlPoint2:CGPointMake(beforeSliderX + (157.44 - beforeSliderOriginalX), 10.73 + 8)];
        [beforeSliderPath addCurveToPoint:CGPointMake(beforeSliderX + (128.03 - beforeSliderOriginalX), 7.17 + 8) controlPoint1:CGPointMake(beforeSliderX + (146.81 - beforeSliderOriginalX), -0.19 + 8) controlPoint2:CGPointMake(beforeSliderX + (135.19 - beforeSliderOriginalX), -0.19 + 8)];
        [beforeSliderPath addCurveToPoint:CGPointMake(beforeSliderX + (122.66 - beforeSliderOriginalX), 20.99 + 8) controlPoint1:CGPointMake(beforeSliderX + (124.32 - beforeSliderOriginalX), 10.97 + 8) controlPoint2:CGPointMake(beforeSliderX + (122.34 - beforeSliderOriginalX), 15.14 + 8)];
        [beforeSliderPath addCurveToPoint:CGPointMake(beforeSliderX, 44 + 8) controlPoint1:CGPointMake(beforeSliderX + (122.96 - beforeSliderOriginalX), 26.43 + 8) controlPoint2:CGPointMake(beforeSliderX, 44 + 8)];
        [beforeSliderPath closePath];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
        [[UIColor darkGrayColor] setFill];
        [beforeSliderPath fill];
        CGContextRestoreGState(context);
        
        [color5 setStroke];
        beforeSliderPath.lineWidth = 0.5;
        [beforeSliderPath stroke];
        
        
        //// Text B Drawing
        CGRect textBRect = CGRectMake((132 + self.beforeSliderXOffset - 8) * scaleX, 14 + 8, (18 + 16) * scaleX, 19);
        [sliderLabelColor setFill];
        [textBContent drawInRect:textBRect withAttributes:sliderBLabelAttributes];
    }
    else {
        UIBezierPath* beforeSliderPath = [UIBezierPath bezierPath];
        [beforeSliderPath moveToPoint: CGPointMake(beforeSliderX + (141.03 - beforeSliderOriginalX), 43.97 + 8 + offsetY)];
        [beforeSliderPath addCurveToPoint: CGPointMake(beforeSliderX + (131.02 - beforeSliderOriginalX - 2), 33.5 + 8 + offsetY - 5) controlPoint1: CGPointMake(beforeSliderX + (141 - beforeSliderOriginalX), 44 + 8 + offsetY) controlPoint2: CGPointMake(beforeSliderX + (135.86 - beforeSliderOriginalX), 39 + 8 + offsetY)];
        [beforeSliderPath addLineToPoint: CGPointMake(beforeSliderX + (150.66 - beforeSliderOriginalX + 2), 33.5 + 8 + offsetY - 5)];
        [beforeSliderPath addCurveToPoint: CGPointMake(beforeSliderX + (141 - beforeSliderOriginalX), 44 + 8 + offsetY) controlPoint1: CGPointMake(beforeSliderX + (145.92 - beforeSliderOriginalX), 39.06 + 8 + offsetY) controlPoint2: CGPointMake(beforeSliderX + (141 - beforeSliderOriginalX), 44 + 8 + offsetY)];
        [beforeSliderPath addLineToPoint: CGPointMake(beforeSliderX + (141.03 - beforeSliderOriginalX), 43.97 + 8 + offsetY)];
        [beforeSliderPath closePath];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
        [[UIColor darkGrayColor] setFill];
        [beforeSliderPath fill];
        CGContextRestoreGState(context);
        
        [color5 setStroke];
        beforeSliderPath.lineWidth = 0.5;
        [beforeSliderPath stroke];
    }
    
    
    float afterSliderX = (141 + self.afterSliderXOffset) * scaleX;
    float afterSliderOriginalX = 141;
    
    //// Before Slider Group
    if (self.compact == NO) {
        //// After Slider Drawing
        UIBezierPath *afterSliderPath = [UIBezierPath bezierPath];
        [afterSliderPath moveToPoint:CGPointMake(afterSliderX, 44 + 8)];
        [afterSliderPath addCurveToPoint:CGPointMake(afterSliderX + (159.34 - afterSliderOriginalX), 67.96 + 8 + offsetY) controlPoint1:CGPointMake(afterSliderX, 44 + 8 + offsetY) controlPoint2:CGPointMake(afterSliderX + (159.03 - afterSliderOriginalX), 62.12 + 8 + offsetY)];
        [afterSliderPath addCurveToPoint:CGPointMake(afterSliderX + (153.97 - afterSliderOriginalX), 80.83 + 8 + offsetY) controlPoint1:CGPointMake(afterSliderX + (159.63 - afterSliderOriginalX), 73.46 + 8 + offsetY) controlPoint2:CGPointMake(afterSliderX + (157.44 - afterSliderOriginalX), 77.27 + 8 + offsetY)];
        [afterSliderPath addCurveToPoint:CGPointMake(afterSliderX + (128.03 - afterSliderOriginalX), 80.83 + 8 + offsetY) controlPoint1:CGPointMake(afterSliderX + (146.81 - afterSliderOriginalX), 88.19 + 8 + offsetY) controlPoint2:CGPointMake(afterSliderX + (135.19 - afterSliderOriginalX), 88.19 + 8 + offsetY)];
        [afterSliderPath addCurveToPoint:CGPointMake(afterSliderX + (122.66 - afterSliderOriginalX), 67.01 + 8 + offsetY) controlPoint1:CGPointMake(afterSliderX + (124.32 - afterSliderOriginalX), 77.03 + 8 + offsetY) controlPoint2:CGPointMake(afterSliderX + (122.34 - afterSliderOriginalX), 72.86 + 8 + offsetY)];
        [afterSliderPath addCurveToPoint:CGPointMake(afterSliderX + (141 - afterSliderOriginalX), 44 + 8 + offsetY) controlPoint1:CGPointMake(afterSliderX + (122.96 - afterSliderOriginalX), 61.57 + 8 + offsetY) controlPoint2:CGPointMake(afterSliderX + (141 - afterSliderOriginalX), 44 + 8 + offsetY)];
        [afterSliderPath closePath];
        
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
        [[UIColor darkGrayColor] setFill];
        [afterSliderPath fill];
        CGContextRestoreGState(context);
        
        [color5 setStroke];
        afterSliderPath.lineWidth = 0.5;
        [afterSliderPath stroke];
        
        //// Text A Drawing
        CGRect textARect = CGRectMake((132 + self.afterSliderXOffset - 8) * scaleX, 61 + 8,
                                       (18 + 16) * scaleX, 19);
        [sliderLabelColor setFill];
        [textAContent drawInRect:textARect withAttributes:sliderALabelAttributes];
    }
    else {
        UIBezierPath* afterSliderPath = [UIBezierPath bezierPath];
        [afterSliderPath moveToPoint: CGPointMake(afterSliderX, 44 + 8 + offsetY)];
        [afterSliderPath addCurveToPoint: CGPointMake(afterSliderX + (150.66 - afterSliderOriginalX + 2), 54.5 + 8 + offsetY + 5) controlPoint1: CGPointMake(afterSliderX + (141 - afterSliderOriginalX), 44 + 8 + offsetY) controlPoint2: CGPointMake(afterSliderX + (145.92 - beforeSliderOriginalX), 48.94 + 8 + offsetY)];
        [afterSliderPath addLineToPoint: CGPointMake(afterSliderX + (131.02 - afterSliderOriginalX - 2), 54.5 + 8 + offsetY + 5)];
        [afterSliderPath addCurveToPoint: CGPointMake(afterSliderX + (141 - afterSliderOriginalX), 44 + 8 + offsetY) controlPoint1: CGPointMake(afterSliderX + (135.86 - afterSliderOriginalX), 49 + 8 + offsetY) controlPoint2: CGPointMake(afterSliderX + (141 - afterSliderOriginalX), 44 + 8 + offsetY)];
        [afterSliderPath closePath];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
        [[UIColor darkGrayColor] setFill];
        [afterSliderPath fill];
        CGContextRestoreGState(context);
        
        [color5 setStroke];
        afterSliderPath.lineWidth = 0.5;
        [afterSliderPath stroke];
    }
    
    
    //// Cleanup
    CGGradientRelease(redToGreen);
    CGColorSpaceRelease(colorSpace);
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self setNeedsDisplay];
}

- (float)ratingBefore {
    return (self.beforeSliderXOffset + 120) / 240 * 6 + 1;
}

- (void)setRatingBefore:(float)ratingBefore {
    float beforeSliderXOffset = (ratingBefore - 1) / 6 * 240 - 120;
    
    if (beforeSliderXOffset < -120) {
        beforeSliderXOffset = -120;
    }
    
    if (beforeSliderXOffset > 120) {
        beforeSliderXOffset = 120;
    }
    
    self.beforeSliderXOffset = beforeSliderXOffset;
    
    [self setNeedsDisplay];
}

- (float)ratingAfter {
    return (self.afterSliderXOffset + 120) / 240 * 6 + 1;
}

- (void)setRatingAfter:(float)ratingAfter {
    float afterSliderXOffset = (ratingAfter - 1) / 6 * 240 - 120;
    
    if (afterSliderXOffset < -120) {
        afterSliderXOffset = -120;
    }
    
    if (afterSliderXOffset > 120) {
        afterSliderXOffset = 120;
    }
    
    self.afterSliderXOffset = afterSliderXOffset;
    
    [self setNeedsDisplay];
}

@end
