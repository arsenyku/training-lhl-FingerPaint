//
//  ViewController.m
//  FingerPaint
//
//  Created by asu on 2015-09-04.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import "FPMainViewController.h"
#import "FPDrawing.h"
#import "FPTextPoint.h"
#import "FPCanvasView.h"


@interface FPMainViewController () <FPCanvasDataSource>

@property (strong, nonatomic) NSMutableArray *drawingsArray;
@property (strong, nonatomic) FPDrawing *currentDrawing;
@property (assign, nonatomic) BOOL isDrawing;
@property (assign, nonatomic) BOOL isErasing;
@property (assign, nonatomic) BOOL isWriting;
@property (assign, nonatomic) BOOL showOptions;


@property (strong, nonatomic) IBOutlet FPCanvasView *canvas;
@property (weak, nonatomic) IBOutlet UIButton *color1;
@property (weak, nonatomic) IBOutlet UIButton *color2;
@property (weak, nonatomic) IBOutlet UIButton *color3;
@property (weak, nonatomic) IBOutlet UIButton *color4;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *smoothButton;
@property (weak, nonatomic) IBOutlet UIButton *eraseButton;
@property (weak, nonatomic) IBOutlet UIButton *textModeButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *box1RightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clearButtonTopConstraint;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftRightSwipeRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *upDownSwipeRecognizer;

@property (strong, nonatomic) UIColor *buttonHighlightColour;
@end

static int const DBG_VERBOSE = 100;
static int const DBG_GESTURE_EVENTS = 3;
static int const DBG_TOUCH_EVENTS = 2;
static int const DBG_QUIET  = 0 ;
static int const DEBUGLEVEL = DBG_QUIET;

static int const EraserWidth = 30;

@implementation FPMainViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _drawingsArray = [NSMutableArray new];
        _currentDrawing = nil;
        _canvas.smoothingMode = Off;
        _isDrawing = NO;
        _isErasing = NO;
        _isWriting = NO;
        _buttonHighlightColour = [UIColor colorWithRed:164.0/255.0 green:205.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.canvas.delegate = self;
    
    self.showOptions = YES;

    [self setupButtons];
    
    
    // Using only one Swipe recognizer would cause only vertical or only horizontal
    // swipes to be recognized even when the direction property was set to include
    // all 4 directions.  Two recognizers were required.
    //
    self.leftRightSwipeRecognizer.delaysTouchesBegan = YES;
    self.leftRightSwipeRecognizer.numberOfTouchesRequired = 2;
    self.leftRightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight ;
    
    self.upDownSwipeRecognizer.delaysTouchesBegan = YES;
    self.upDownSwipeRecognizer.numberOfTouchesRequired = 2;
    self.upDownSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown ;
    [self.upDownSwipeRecognizer requireGestureRecognizerToFail:self.leftRightSwipeRecognizer];
    
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

    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    if (self.isWriting){
        [self writingBeganAtPoint:point];
        return;
    }
    
    self.isDrawing = YES;
    
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
    switch (self.canvas.smoothingMode) {
        case Off:
            self.canvas.smoothingMode = Overlay;
            break;

        case Overlay:
            self.canvas.smoothingMode = SmoothOnly;
            break;
            
        case SmoothOnly:
        default:
            self.canvas.smoothingMode = Off;
            break;
    }
    
    [self refresh];
}

- (IBAction)eraserMode:(id)sender {
    self.currentDrawing.strokeWidth = EraserWidth;
    self.currentDrawing.brushColour = self.view.backgroundColor;
    self.isErasing = YES;
    self.isWriting = NO;
    
    [self refresh];
}

- (IBAction)colourButtonPressed:(UIButton *)sender {
    self.currentDrawing.strokeWidth = 1.0;
    self.currentDrawing.brushColour = sender.backgroundColor;
    self.isErasing = NO;
    self.isWriting = NO;

    [self refresh];
}

- (IBAction)textMode:(UIButton *)sender {
    if (self.isErasing)
        self.currentDrawing.brushColour = self.color1.backgroundColor;
    
    self.isWriting = YES;
    self.isErasing = NO;

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
    
    for (id content in self.drawingsArray) {
        
        if ([content isKindOfClass:[FPDrawing class]]){
            FPDrawing* drawing = content;
            NSMutableArray *pointsForDrawing = [NSMutableArray new];
            for (NSArray *point in drawing.points) {
                [pointsForDrawing addObject:point];
            }
            
            NSDictionary *drawingData = @{ @"colour":drawing.brushColour,
                                           @"width":[NSNumber numberWithInt:drawing.strokeWidth],
                                           @"points":pointsForDrawing };
            
            [result addObject:drawingData];
        }
        
        if ([content isKindOfClass:[FPTextPoint class]]){
            FPTextPoint *textPoint = content;
            
            NSDictionary *textPointData = @{ @"text":textPoint.text,
                                             @"font":textPoint.font,
                                             @"colour":textPoint.colour,
                                             @"point":textPoint.pointAsValue
                                            };
            [result addObject:textPointData];
        }
    }
    
    return result;
}


#pragma mark - private

-(void)setupButtons{

    NSArray *buttons = @[self.color1, self.color2, self.color3, self.color4,
                         self.eraseButton, self.textModeButton];
    
    for (UIButton *button in buttons) {
        button.layer.cornerRadius = 10;
        button.clipsToBounds = YES;
    }
    
    self.eraseButton.layer.borderWidth = 0.5f;
    self.eraseButton.layer.borderColor = [self.buttonHighlightColour CGColor];
    self.textModeButton.layer.borderWidth = 0.5f;
    self.textModeButton.layer.borderColor = [self.buttonHighlightColour CGColor];

}

-(void)toggleButtonAppearance{
    [UIView animateWithDuration:0.3 animations:^{
        NSArray *buttons = @[self.color1, self.color2, self.color3, self.color4,
                             self.eraseButton, self.textModeButton,
                             self.clearButton, self.undoButton, self.smoothButton];
        
        for (UIButton *button in buttons) {
            button.alpha = self.isDrawing ? 0.0 : 1.0;
        }
    }];
    
    if (self.isErasing)
        self.eraseButton.backgroundColor = self.buttonHighlightColour;
    else
        self.eraseButton.backgroundColor = self.view.backgroundColor;
    
    if (self.isWriting)
        self.textModeButton.backgroundColor = self.buttonHighlightColour;
    else
        self.textModeButton.backgroundColor = self.view.backgroundColor;
    
    switch(self.canvas.smoothingMode){
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

-(void)toggleControlPosition{
    [UIView animateWithDuration:0.5 animations:^{
        self.box1RightConstraint.constant = self.showOptions ? 0.0 : 1000.0 ;
        self.clearButtonTopConstraint.constant = self.showOptions ? +20.0 : -100.0 ;
        [self.view layoutIfNeeded];
    }];
}


-(void)refresh{
    [self toggleControlPosition];
    [self toggleButtonAppearance];
    
    [self.view setNeedsDisplay];
}

-(void)startNewDrawingWithColour:(UIColor*)colour{
    self.currentDrawing = [FPDrawing new];
    self.currentDrawing.brushColour = colour;
    self.currentDrawing.strokeWidth = self.isErasing ? EraserWidth : 1.0;
    [self.drawingsArray addObject:self.currentDrawing];
}

-(void)writingBeganAtPoint:(CGPoint)point{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Enter some text"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   NSString* text = ((UITextField*)alertController.textFields.firstObject).text;

                                                   [self.drawingsArray removeLastObject];
                                                   
                                                   [self.drawingsArray addObject:[[FPTextPoint alloc] initWithText:text
                                                                                                           atPoint:point
                                                                                                            colour:self.currentDrawing.brushColour
                                                                                                          fontSize:15]];

                                                   [self.drawingsArray addObject:self.currentDrawing];
                                                   
                                                   self.isWriting = NO;
                                                   [self refresh];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       self.isWriting = NO;
                                                       [self refresh];
                                                   }];
    
    [alertController addAction:ok];
    [alertController addAction:cancel];
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}
@end
