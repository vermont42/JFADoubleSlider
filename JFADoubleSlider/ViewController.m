//
//  ViewController.m
//  DoubleSlider
//
//  Created by Josh Adams on 1/10/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import "ViewController.h"
#import "JFADoubleSlider.h"

@interface ViewController () <JFADoubleSliderDelegate, UIAlertViewDelegate, UITextFieldDelegate>
typedef enum
{
    ABS_MIN = 0,
    CUR_MIN = 1,
    CUR_MAX = 2,
    ABS_MAX = 4
} AlertViewState;
@property (nonatomic) AlertViewState alertViewState;
@property (nonatomic) BOOL firstTime;
@property (strong, nonatomic) IBOutlet JFADoubleSlider *iBDoubleSlider;
@property (strong, nonatomic) IBOutlet UISwitch *showValuesSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *isIntSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *continuousSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *animateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *modifySwitch;
@property (strong, nonatomic) IBOutlet UIButton *signButton;
@property (strong, nonatomic) IBOutlet UITextView *outputView;
@property (strong, nonatomic) IBOutlet UITextView *absValsView;
@property (strong, nonatomic) JFADoubleSlider *currentSlider;
@property (strong, nonatomic) JFADoubleSlider *programmaticSlider;
@property (strong, nonatomic) UIAlertView *changeValueAlert;
@end

@implementation ViewController
static const int LABEL_FONT_SIZE = 22;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.animateSwitch.on = YES;
    self.iBDoubleSlider.delegate = self;
    self.programmaticSlider = [[JFADoubleSlider alloc] initWithFrame:self.view.frame];
    self.programmaticSlider.delegate = self;
    self.programmaticSlider.absMinVal = -5000.0;
    self.programmaticSlider.absMaxVal = 5000.0;
    self.programmaticSlider.curMinVal = -1420.0;
    self.programmaticSlider.curMaxVal = 1420.0;
    self.programmaticSlider.reportInteger = YES;
    [self.view addSubview:self.programmaticSlider];
    UILabel *label = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"Programmatic Double Slider";
    label.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    [label sizeToFit];
    [self.view addSubview:label];
    NSDictionary *viewDict = @{@"slider":self.programmaticSlider, @"label":label};
    NSArray *vertConstr = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[label][slider]-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewDict];
    [self.view addConstraints:vertConstr];
    NSArray *horizConstr = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[slider]-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDict];
    [self.view addConstraints:horizConstr];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    self.outputView.text = @"";
    self.outputView.editable = NO;
    self.firstTime = YES;
    self.currentSlider = self.iBDoubleSlider;
    self.showValuesSwitch.on = self.currentSlider.showValues;
    self.isIntSwitch.on = self.currentSlider.reportInteger;
    self.continuousSwitch.on = self.currentSlider.isContinuous;
    [self updateAbsValsView];
}

- (void)updateAbsValsView
{
    if (self.currentSlider.reportInteger)
    {
        self.absValsView.text = [NSString stringWithFormat:@"Abs Max: %d\nAbs Min: %d",
                                 (int)self.currentSlider.absMaxVal, (int)self.currentSlider.absMinVal];
    }
    else
    {
        NSString *formatString = [NSString stringWithFormat:@"Abs Max: %%.0%df\nAbs Min: %%.0%df",
                                  self.currentSlider.precision, self.currentSlider.precision];
        self.absValsView.text = [NSString stringWithFormat:formatString,
                                 self.currentSlider.absMaxVal, self.currentSlider.absMinVal];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)changeValue:(float)currentValue promptPreamble:(NSString *)promptPreamble
{
    NSString *fullPrompt;
    if (self.currentSlider.reportInteger)
    {
        fullPrompt = [NSString stringWithFormat:@"%@ value is %ld. Enter a new value.", promptPreamble, lroundf(currentValue)];
    }
    else
    {
        fullPrompt = [NSString stringWithFormat:@"%@ value is %.02f. Enter a new value.", promptPreamble, currentValue];
    }
    self.changeValueAlert = [[UIAlertView alloc]
                             initWithTitle: nil
                             message:fullPrompt
                             delegate: self
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@"OK", nil];
    self.changeValueAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.changeValueAlert textFieldAtIndex:0].delegate = self;
    // See http://stackoverflow.com/questions/24871532/xcode-ios-8-keyboard-types-not-supported/24888849#24888849 &
    // http://stackoverflow.com/questions/4694854/iphone-cant-find-keyplane-that-supports-type-8-for-keyboard-iphone-portrait-de?lq=1
    // for a spurious error message that the following line causes in the Simulator.
    [self.changeValueAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    [self.changeValueAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        int signMultiplier = [self.signButton.currentTitle isEqualToString:@"+"] ? 1 : -1;
        NSString *textFieldText = [alertView textFieldAtIndex:0].text;
        if (![textFieldText isEqualToString:@""])
        {
            switch (self.alertViewState)
            {
                case ABS_MAX:
                    self.currentSlider.absMaxVal = [textFieldText floatValue] * signMultiplier;
                    [self updateAbsValsView];
                    break;
                case CUR_MAX:
                    [self.currentSlider setCurMaxVal:[textFieldText floatValue] * signMultiplier animated:self.animateSwitch.on];
                    break;
                case CUR_MIN:
                    [self.currentSlider setCurMinVal:[textFieldText floatValue] * signMultiplier animated:self.animateSwitch.on];
                    break;
                case ABS_MIN:
                    self.currentSlider.absMinVal = [textFieldText floatValue] * signMultiplier;
                    [self updateAbsValsView];
                    break;
            }
        }
    }
    [[alertView textFieldAtIndex:0] resignFirstResponder];
}

- (IBAction)changeCurMax
{
    self.alertViewState = CUR_MAX;
    [self changeValue:self.currentSlider.curMaxVal promptPreamble:@"Current maximum"];
}

- (IBAction)changeAbsMax
{
    self.alertViewState = ABS_MAX;
    [self changeValue:self.currentSlider.absMaxVal promptPreamble:@"Absulute maximum"];
}

- (IBAction)changeCurMin:(UIButton *)sender
{
    self.alertViewState = CUR_MIN;
    [self changeValue:self.currentSlider.curMinVal promptPreamble:@"Current minimum"];
}

- (IBAction)changeAbsMin
{
    self.alertViewState = ABS_MIN;
    [self changeValue:self.currentSlider.absMinVal promptPreamble:@"Absolute minimum"];
}

- (IBAction)changeShowValues:(UISwitch *)sender
{
    self.currentSlider.showValues = sender.isOn;
}

- (IBAction)changeIsInt:(UISwitch *)sender
{
    self.currentSlider.reportInteger = sender.isOn;
    [self updateAbsValsView];
}

- (IBAction)changeContinuous:(UISwitch *)sender
{
    self.currentSlider.continuous = sender.isOn;
}

- (IBAction)changeCurrentSlider:(UISwitch *)sender
{
    if (sender.on)
    {
        self.currentSlider = self.programmaticSlider;
    }
    else
    {
        self.currentSlider = self.iBDoubleSlider;
    }
    self.currentSlider.reportInteger = self.isIntSwitch.on;
    self.currentSlider.showValues = self.showValuesSwitch.on;
    self.currentSlider.continuous = self.self.continuousSwitch.on;
    [self updateAbsValsView];
}

- (void)minValueChanged:(float)minValue
{
    [self displayOutput:[NSString stringWithFormat:@"Min float value: %.02f", minValue]];
}

- (void)maxValueChanged:(float)maxValue
{
    [self displayOutput:[NSString stringWithFormat:@"Max float value: %.02f", maxValue]];
}

- (void)minIntValueChanged:(int)minIntValue
{
    [self displayOutput:[NSString stringWithFormat:@"Min int value: %d", minIntValue]];
}

- (void)maxIntValueChanged:(int)maxIntValue
{
    [self displayOutput:[NSString stringWithFormat:@"Max int value: %d", maxIntValue]];
}

- (IBAction)changeSign:(UIButton *)sender
{
    if ([self.signButton.currentTitle isEqualToString:@"-"])
    {
        [self.signButton setTitle:@"+" forState:UIControlStateNormal];
    }
    else
    {
        [self.signButton setTitle:@"-" forState:UIControlStateNormal];
    }
}

- (void)displayOutput:(NSString *)output
{
    if (self.firstTime)
    {
        self.outputView.text = output;
        self.firstTime = NO;
    }
    else
    {
        self.outputView.text = [NSString stringWithFormat:@"%@\n%@", output, self.outputView.text];
        [self.outputView flashScrollIndicators];
    }
}
@end
