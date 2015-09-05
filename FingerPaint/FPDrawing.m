//
//  FPDrawing.m
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import "FPDrawing.h"


@interface FPDrawing()

@property NSMutableArray *pointsList;

@end

@implementation FPDrawing
- (instancetype)init
{
    self = [super init];
    if (self) {
        _brushColour = [UIColor blackColor];
        _strokeWidth = 10;
        _pointsList = [NSMutableArray new];
    }
    return self;
}

-(NSArray *)points{
    return [self.pointsList copy];
}

-(void)addPoint:(CGPoint)point{
    [self.pointsList addObject:[NSValue valueWithCGPoint:point]];
}

@end
