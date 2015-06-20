//
//  JFADoubleSlider.h
//  JFADoubleSlider
//
//  Created by Josh Adams on 1/10/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

// This protocol is for informing the delegate when the values of the sliders change.
@protocol JFADoubleSliderDelegate <NSObject>
@optional
- (void)minValueChanged:(float)minValue;
- (void)maxValueChanged:(float)minValue;
- (void)minIntValueChanged:(int)minIntValue;
- (void)maxIntValueChanged:(int)maxIntValue;
@end

IB_DESIGNABLE
@interface JFADoubleSlider : UIView
@property (nonatomic, retain) IBInspectable UIColor *inColor; // line color between knobs
@property (nonatomic, retain) IBInspectable UIColor *outColor; // line color outside knobs
@property (nonatomic, retain) IBInspectable UIColor *valueColor; // color of knob values
@property (nonatomic, retain) IBInspectable UIColor *knobStrokeColor; // knob outline color
@property (nonatomic, retain) IBInspectable UIColor *knobFillColor; // knob internal color
@property (nonatomic) IBInspectable float absMinVal; // lowest possible value of left knob
@property (nonatomic) IBInspectable float absMaxVal; // highest possible value of right knob
@property (nonatomic) IBInspectable float curMinVal; // current value of left knob
@property (nonatomic) IBInspectable float curMaxVal; // current value of right knob
@property (nonatomic) IBInspectable int precision; // number of digits after decimal point to show
@property (nonatomic) IBInspectable BOOL reportInteger; // display and report knob values as ints
@property (nonatomic) IBInspectable BOOL showValues; // show knob values below knobs
@property (nonatomic, getter=isContinuous) IBInspectable BOOL continuous; // report new knob values as they change
@property (weak, nonatomic) IBOutlet id<JFADoubleSliderDelegate> delegate; // see JFADoubleSliderDelegate comment
- (void)setCurMaxVal:(float)curMaxVal animated:(BOOL)animated; // set right knob value, possiby animating
- (void)setCurMinVal:(float)curMinVal animated:(BOOL)animated; // set left knob value, possibly animating
@end
