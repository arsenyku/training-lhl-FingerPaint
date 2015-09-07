//
//  FPCanvas.m
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import "FPCanvasView.h"
#import "UIBezierPath+Interpolation.h"


@implementation FPCanvasView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.delegate == nil)
        return;
    
    NSArray *drawings = [self.delegate drawings];

    SmoothingMode smoothingMode = self.delegate.smoothingMode;

    for (NSDictionary *drawingData in drawings) {
        UIBezierPath *path = [UIBezierPath new];

        UIColor *brushColour = drawingData[ @"colour" ];
        UIColor *overlayColour = [self invertColour:brushColour];
        
        int strokeWidth = [(NSNumber*)drawingData[ @"width" ] intValue];

        NSArray *drawingPoints = drawingData[ @"points" ];
        
        if ([drawingPoints count] < 1)
            continue;
        
        CGPoint firstPoint = [((NSValue*)(drawingPoints[0])) CGPointValue];
        [path moveToPoint:firstPoint];

        
        for (NSValue *pointValue in drawingPoints) {
            
            CGPoint point = [pointValue CGPointValue];
            
            if (point.x == firstPoint.x && point.y == firstPoint.y)
                continue;
            
            [path addLineToPoint:point];
        }
        
        UIBezierPath *interpolated = [UIBezierPath interpolateCGPointsWithHermite:drawingPoints closed:NO];

        interpolated.lineWidth = strokeWidth;
        path.lineWidth = strokeWidth;
        
        switch (smoothingMode) {
            case Off:
                [brushColour setStroke];
                [path stroke];
                break;
                
            case Overlay:
                [overlayColour setStroke];
                [interpolated stroke];
                [brushColour setStroke];
                [path stroke];
                break;
                
            case SmoothOnly:
            default:
                [brushColour setStroke];
                [interpolated stroke];
                break;
        }
        
    }
}

-(UIColor*)invertColour:(UIColor*)colour{
    CGFloat hue, saturation, brightness, alpha;
    [colour getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

    return [UIColor colorWithHue:1.0-hue saturation:saturation brightness:brightness alpha:alpha];
}

@end
