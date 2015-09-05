//
//  FPCanvas.m
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import "FPCanvasView.h"

@implementation FPCanvasView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.delegate == nil)
        return;
    
    NSArray *drawings = [self.delegate drawings];


    for (NSDictionary *drawingData in drawings) {
        UIBezierPath *path = [UIBezierPath new];

        UIColor *brushColour = drawingData[ @"colour" ];
        [brushColour setStroke];
        
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
        
        [path stroke];
        
    }
}




@end
