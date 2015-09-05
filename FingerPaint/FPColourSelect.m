//
//  FPColorSelect.m
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import "FPColourSelect.h"

@implementation FPColourSelect


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate colourPicked:self.backgroundColor];
}

@end
