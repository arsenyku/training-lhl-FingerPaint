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
@property (assign, nonatomic) SmoothingMode lineSmoothing;
@property (assign, nonatomic) BOOL isDrawing;
@property (assign, nonatomic) BOOL showOptions;


@property (strong, nonatomic) IBOutlet FPCanvasView *canvas;
@property (weak, nonatomic) IBOutlet FPColourSelect *color1;
@property (weak, nonatomic) IBOutlet FPColourSelect *color2;
@property (weak, nonatomic) IBOutlet FPColourSelect *color3;
@property (weak, nonatomic) IBOutlet FPColourSelect *color4;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *smoothButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *box1RightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clearButtonTopConstraint;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRecognizer;
@end

static int const DBG_VERBOSE = 100;
static int const DBG_GESTURE_EVENTS = 3;
static int const DBG_TOUCH_EVENTS = 2;
static int const DBG_QUIET  = 0 ;
static int const DEBUGLEVEL = DBG_QUIET;

@implementation FPMainViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _drawingsArray = [NSMutableArray new];
        _currentDrawing = nil;
        _lineSmoothing = NO;
        _isDrawing = NO;
    }
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.canvas.delegate = self;
    
    self.color1.delegate = self;
    self.color2.delegate = self;
    self.color3.delegate = self;
    self.color4.delegate = self;
    self.showOptions = YES;

    self.swipeRecognizer.delaysTouchesBegan = YES;
    self.swipeRecognizer.numberOfTouchesRequired = 2;
    self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft |
                                     UISwipeGestureRecognizerDirectionRight |
    								 UISwipeGestureRecognizerDirectionUp |
    								 UISwipeGestureRecognizerDirectionDown 	;
    
    [self startNewDrawingWithColour:self.color1.backgroundColor];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - touch events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (DEBUGLEVEL == DBG_TOUCH_EVENTS || DEBUGLEVEL >= DBG_VERBOSE)
    	NSLog(@"BEGAN:  << %lu >> %@", (unsigned long)[touches count], touches);

    self.isDrawing = YES;
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [self.currentDrawing addPoint:point];

    [self refresh];

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (DEBUGLEVEL == DBG_TOUCH_EVENTS || DEBUGLEVEL >= DBG_VERBOSE)
	    NSLog(@"MOVED: %@", touches);
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [self.currentDrawing addPoint:point];
    [self refresh];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (DEBUGLEVEL == DBG_TOUCH_EVENTS || DEBUGLEVEL >= DBG_VERBOSE)
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

- (IBAction)undo:(id)sender {
    if ([self.drawings count] < 2)
        return;

    int lastCompleteDrawingIndex = (int)[self.drawings count] - 2;
    
    [self.drawingsArray removeObjectAtIndex:lastCompleteDrawingIndex ];
    
    [self refresh];
}

- (IBAction)smoothLinesToggle:(id)sender {
    switch (self.lineSmoothing) {
        case Off:
            self.lineSmoothing = Overlay;
            break;

        case Overlay:
            self.lineSmoothing = SmoothOnly;
            break;
            
        case SmoothOnly:
        default:
            self.lineSmoothing = Off;
            break;
    }
    
    [self refresh];
}

- (IBAction)swipeDetected:(id)sender {
    if (DEBUGLEVEL == DBG_GESTURE_EVENTS || DEBUGLEVEL >= DBG_VERBOSE)
	    NSLog(@"SWIPE: %@", sender);

    self.showOptions = ! self.showOptions;
    [self refresh];
}


#pragma mark - <FPCanvasDataSource>

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

-(SmoothingMode)smoothingMode{
    return self.lineSmoothing;
}
#pragma mark - <FPColorChangeDelegate>

-(void)colourPicked:(UIColor *)pickedColour{
    self.currentDrawing.brushColour = pickedColour;
}

#pragma mark - private



-(void)toggleControlVisibility{
    [UIView animateWithDuration:0.3 animations:^{
        self.color1.alpha = self.isDrawing ? 0.0 : 1.0;
        self.color2.alpha = self.isDrawing ? 0.0 : 1.0;
        self.color3.alpha = self.isDrawing ? 0.0 : 1.0;
        self.color4.alpha = self.isDrawing ? 0.0 : 1.0;
        self.clearButton.alpha = self.isDrawing ? 0.0 : 1.0;
        self.undoButton.alpha = self.isDrawing ? 0.0 : 1.0;
        self.smoothButton.alpha = self.isDrawing ? 0.0 : 1.0;
    }];
}

-(void)toggleControlPosition{
    [UIView animateWithDuration:0.5 animations:^{
        self.box1RightConstraint.constant = self.showOptions ? 0.0 : 1000.0 ;
        self.clearButtonTopConstraint.constant = self.showOptions ? +20.0 : -100.0 ;
        [self.view layoutIfNeeded];
    }];
}

-(void)adjustSmoothingText{
    switch(self.lineSmoothing){
        case Off:
            [self.smoothButton setTitle:@"No Smoothing" forState:UIControlStateNormal];
            break;
            
        case Overlay:
            [self.smoothButton setTitle:@"Overlay" forState:UIControlStateNormal];
            break;
            
        case SmoothOnly:
        default:
            [self.smoothButton setTitle:@"Smooth Lines" forState:UIControlStateNormal];
            break;
    }
}

-(void)refresh{
    [self toggleControlPosition];
    [self toggleControlVisibility];
    [self adjustSmoothingText];
    
    [self.view setNeedsDisplay];
}

-(void)startNewDrawingWithColour:(UIColor*)colour{
    self.currentDrawing = [FPDrawing new];
    self.currentDrawing.brushColour = colour;
    [self.drawingsArray addObject:self.currentDrawing];
}

@end
