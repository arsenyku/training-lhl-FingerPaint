//
//  FPCanvas.h
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, SmoothingMode) {
    Off,
    Overlay,
    SmoothOnly
};

@protocol FPCanvasDataSource <NSObject>
-(NSArray*)drawings;
-(SmoothingMode)smoothingMode;
@end

@interface FPCanvasView : UIView
@property (nonatomic, weak) id<FPCanvasDataSource> delegate;
@end
