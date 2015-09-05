//
//  FPColorSelect.h
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FPColourChangeDelegate <NSObject>
-(void)colourPicked:(UIColor*)pickedColour;
@end

@interface FPColourSelect : UIView
@property (nonatomic, strong) id<FPColourChangeDelegate> delegate;
@end
