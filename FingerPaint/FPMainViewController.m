//
//  ViewController.m
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import "FPMainViewController.h"
#import "FPDrawing.h"
#import "FPCanvasView.h"
#import "FPColourSelect.h"

@interface FPMainViewController () <FPCanvasDataSource, FPColourChangeDelegate>

@property (strong, nonatomic) NSMutableArray *drawingsArray;
@property (strong, nonatomic) FPDrawing *currentDrawing;
@property (assign, nonatomic) BOOL isDrawing;

@property (strong, nonatomic) IBOutlet FPCanvasView *canvas;
@property (weak, nonatomic) IBOutlet FPColourSelect *color1;
@property (weak, nonatomic) IBOutlet FPColourSelect *color2;
@property (weak, nonatomic) IBOutlet FPColourSelect *color3;
@property (weak, nonatomic) IBOutlet FPColourSelect *color4;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@end

@implementation FPMainViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _drawingsArray = [NSMutableArray new];
        _currentDrawing = nil;
    }
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.canvas.delegate = self;
    
    self.color1.backgroundColor = [UIColor blueColor];
    self.color2.backgroundColor = [UIColor redColor];
    self.color3.backgroundColor = [UIColor greenColor];
    self.color4.backgroundColor = [UIColor yellowColor];
    
    self.color1.delegate = self;
    self.color2.delegate = self;
    self.color3.delegate = self;
    self.color4.delegate = self;

    [self startNewDrawingWithColour:self.color1.backgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - touch events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"BEGAN:  << %lu >> %@", (unsigned long)[touches count], touches);

    self.isDrawing = YES;
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [self.currentDrawing addPoint:point];
    [self.drawingsArray addObject:self.currentDrawing];

    [self refresh];

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"MOVED: %@", touches);
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [self.currentDrawing addPoint:point];
    [self refresh];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"ENDED: << %lu >> %@", (unsigned long)[touches count], touches);
    
    self.isDrawing = NO;

    UIColor *lastColour = self.currentDrawing.brushColour;
    [self startNewDrawingWithColour:lastColour];
    
    [self refresh];
}


- (IBAction)clearCanvas:(id)sender {
    UIColor *lastColour = self.currentDrawing.brushColour;
    [self.drawingsArray removeAllObjects];

    [self startNewDrawingWithColour:lastColour];
    
    [self refresh];
}

#pragma mark - <FPLineDrawingDelegate>

-(NSArray *)drawings{
    NSMutableArray *result = [NSMutableArray new];
    
    for (FPDrawing *drawing in self.drawingsArray) {
        NSMutableArray *pointsForDrawing = [NSMutableArray new];
        for (NSArray *point in drawing.points) {
            [pointsForDrawing addObject:point];
        }
 
        NSDictionary *drawingData = @{ @"colour":drawing.brushColour,
                                       @"points":pointsForDrawing };
        
        [result addObject:drawingData];
    }
    
    return result;
}

#pragma mark - <FPColorChangeDelegate>

-(void)colourPicked:(UIColor *)pickedColour{
    self.currentDrawing.brushColour = pickedColour;
}

#pragma mark - private

-(void)toggleControl:(UIView*)view{
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = self.isDrawing ? 0 : 1 ;
    }];
    view.userInteractionEnabled = !self.isDrawing;
}

-(void)refresh{
    [self toggleControl:self.color1];
    [self toggleControl:self.color2];
    [self toggleControl:self.color3];
    [self toggleControl:self.color4];
    [self toggleControl:self.clearButton];
    
    [self.view setNeedsDisplay];
}

-(void)startNewDrawingWithColour:(UIColor*)colour{
    self.currentDrawing = [FPDrawing new];
    self.currentDrawing.brushColour = colour;
    [self.drawingsArray addObject:self.currentDrawing];
}

@end