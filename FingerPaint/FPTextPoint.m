//
//  FPTextPoint.m
//  FingerPaint
//
//  Created by asu on 2015-09-06.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import "FPTextPoint.h"

@implementation FPTextPoint
- (instancetype)init{
    return [self initWithText:@"" atPoint:CGPointMake(0, 0) colour:[UIColor blackColor] fontSize:15];
}
-(instancetype)initWithText:(NSString*)text atPoint:(CGPoint)point colour:(UIColor*)colour fontSize:(float)fontSize;
{
    self = [super init];
    if (self) {
        _colour = colour;
        _font = [UIFont systemFontOfSize:fontSize];
        _text = text;
        _point = point;
    }
    return self;
}
-(NSValue*)pointAsValue{
    return [NSValue valueWithCGPoint:self.point];
}

@end
