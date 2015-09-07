//
//  FPTextPoint.h
//  FingerPaint
//
//  Created by asu on 2015-09-06.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FPTextPoint : NSObject
@property (strong, nonatomic) UIColor *colour;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) CGPoint point;

-(instancetype)initWithText:(NSString*)text atPoint:(CGPoint)point colour:(UIColor*)colour fontSize:(float)fontSize;
-(NSValue*)pointAsValue;
@end
