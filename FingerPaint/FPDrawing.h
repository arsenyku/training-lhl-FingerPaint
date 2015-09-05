//
//  FPDrawing.h
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FPDrawing : NSObject
@property (assign, nonatomic) UIColor *brushColour;
@property (assign, nonatomic) int strokeWidth;

-(NSArray*)points;
-(void)addPoint:(CGPoint)point;
@end
