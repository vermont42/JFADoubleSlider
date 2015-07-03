//
//  JFADoubleSlider.m
//  JFADoubleSlider
//
//  Created by Josh Adams on 1/10/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import "JFADoubleSlider.h"

@interface JFADoubleSlider ()
typedef enum
{
    LEFT_KNOB = 0,
    RIGHT_KNOB = 1,
    NEITHER = 2
} CurrentKnob;
@property (nonatomic) CurrentKnob currentKnob;
@property (nonatomic) float minValSpan;
@property (nonatomic) float valueFudge;
@property (nonatomic) float deltaPerFrame;
@property (nonatomic) float targetCurVal;
@property (nonatomic) BOOL doneSettingUp;
@property (nonatomic) BOOL panHappening;
@property (nonatomic) BOOL animationHappening;
@property (strong, nonatomic) NSTimer *animationTimer;
@end

@implementation JFADoubleSlider
#define TEXT_COLOR [UIColor blackColor];
#define OUT_COLOR [UIColor lightGrayColor];
#define BACKGROUND_COLOR [UIColor clearColor];
#define VALUE_COLOR [UIColor blackColor];
#define KNOB_STROKE_COLOR [UIColor blackColor];
#define KNOB_FILL_COLOR [UIColor whiteColor];
static const CGFloat LINE_WIDTH = 2.0;
static const CGFloat KNOB_BORDER_WIDTH = 1.0;
static const CGFloat KNOB_WIDTH = 28.0;
static const CGFloat INTRINSIC_HEIGHT = 62.0;
static const float FUDGE_FACTOR = 100.0;
static const float ANIMATION_FRACTION = .0067;
static const float FRAME_DURATION = .03;
static const float ABS_MIN_VAL = 0.0;
static const float ABS_MAX_VAL = 1.0;
static const float CUR_MIN_VAL = .3;
static const float CUR_MAX_VAL = .7;
static const int PRECISION = 1;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setAbsMaxVal:(float)absMaxVal
{
    if (!_doneSettingUp || absMaxVal > _curMaxVal)
    {
        _absMaxVal = absMaxVal;
        [self setNeedsDisplay];
    }
}

- (BOOL)proposedCurMaxValIsGood:(float)proposedCurMaxVal
{
    if (!_doneSettingUp || (proposedCurMaxVal > _curMinVal && proposedCurMaxVal <= _absMaxVal))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)setCurMaxVal:(float)curMaxVal
{
    if ([self proposedCurMaxValIsGood:curMaxVal])
    {
        int prevIntCurMaxVal = (int)lroundf(_curMaxVal);
        _curMaxVal = curMaxVal;
        if (!self.animationHappening && (self.isContinuous || !self.panHappening))
        {
            if (self.reportInteger)
            {
                int newIntCurMaxVal = (int)lroundf(curMaxVal);
                if (prevIntCurMaxVal != newIntCurMaxVal  || !self.panHappening)
                {
                    if ([self.delegate respondsToSelector:@selector(maxIntValueChanged:)])
                    {
                        [self.delegate maxIntValueChanged:newIntCurMaxVal];
                    }
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(maxValueChanged:)])
                {
                    [self.delegate maxValueChanged:_curMaxVal];
                }
            }
        }
        [self setNeedsDisplay];
    }
}

- (void)setCurMaxVal:(float)curMaxVal animated:(BOOL)animated
{
    self.doneSettingUp = YES;
    if ([self proposedCurMaxValIsGood:curMaxVal])
    {
        if (!animated)
        {
            _curMaxVal = curMaxVal;
            [self setNeedsDisplay];
        }
        else
        {
            self.targetCurVal = curMaxVal;
            float virtualWidth = _absMaxVal - _absMinVal;
            self.deltaPerFrame = virtualWidth * ANIMATION_FRACTION;
            if (curMaxVal < _curMaxVal)
            {
                self.deltaPerFrame *= -1;
            }
            self.animationHappening = YES;
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:FRAME_DURATION
                                                                   target:self
                                                                 selector:@selector(updateRightKnob:)
                                                                 userInfo:nil
                                                                  repeats:YES];
        }
    }
}

- (void)updateRightKnob:(NSTimer *)timer
{
    self.curMaxVal += self.deltaPerFrame;
    if ((self.deltaPerFrame > 0 && self.curMaxVal > self.targetCurVal) ||
        (self.deltaPerFrame < 0 && self.curMaxVal + self.deltaPerFrame < self.targetCurVal))
    {
        self.animationHappening = NO;
        self.curMaxVal = self.targetCurVal;
        [timer invalidate];
    }
    [self setNeedsDisplay];
}

- (BOOL)proposedCurMinValIsGood:(float)proposedCurMinVal
{
    if (!_doneSettingUp || (proposedCurMinVal < _curMaxVal && proposedCurMinVal >= _absMinVal))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)setCurMinVal:(float)curMinVal
{
    if ([self proposedCurMinValIsGood:curMinVal])
    {
        int prevIntCurMinVal = (int)lroundf(_curMinVal);
        _curMinVal = curMinVal;
        if (!self.animationHappening && (self.isContinuous || !self.panHappening))
        {
            if (self.reportInteger)
            {
                int newIntCurMinVal = (int)lroundf(curMinVal);
                if (prevIntCurMinVal != newIntCurMinVal || !self.panHappening)
                {
                    if ([self.delegate respondsToSelector:@selector(minIntValueChanged:)])
                    {
                        [self.delegate minIntValueChanged:newIntCurMinVal];
                    }
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(minValueChanged:)])
                {
                    [self.delegate minValueChanged:_curMinVal];
                }
            }
        }
        [self setNeedsDisplay];
    }
}

- (void)setCurMinVal:(float)curMinVal animated:(BOOL)animated
{
    self.doneSettingUp = YES;
    if ([self proposedCurMinValIsGood:curMinVal])
    {
        if (!animated)
        {
            _curMinVal = curMinVal;
            [self setNeedsDisplay];
        }
        else
        {
            self.targetCurVal = curMinVal;
            float virtualWidth = _absMaxVal - _absMinVal;
            self.deltaPerFrame = virtualWidth * ANIMATION_FRACTION;
            if (curMinVal < _curMinVal)
            {
                self.deltaPerFrame *= -1;
            }
            self.animationHappening = YES;
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:FRAME_DURATION
                                                                   target:self
                                                                 selector:@selector(updateLeftKnob:)
                                                                 userInfo:nil
                                                                  repeats:YES];
        }
    }
}

- (void)updateLeftKnob:(NSTimer *)timer
{
    self.curMinVal += self.deltaPerFrame;
    if ((self.deltaPerFrame > 0 && self.curMinVal + self.deltaPerFrame > self.targetCurVal) ||
        (self.deltaPerFrame < 0 && self.curMinVal < self.targetCurVal))
    {
        self.animationHappening = NO;
        self.curMinVal = self.targetCurVal;
        [timer invalidate];
    }
    [self setNeedsDisplay];
}

- (void)setAbsMinVal:(float)absMinVal
{
    if (!_doneSettingUp || absMinVal < _curMinVal)
    {
        _absMinVal = absMinVal;
        [self setNeedsDisplay];
    }
}

- (void)setReportInteger:(BOOL)reportInteger
{
    _reportInteger = reportInteger;
    [self setNeedsDisplay];
}

- (void)setShowValues:(BOOL)showValues
{
    _showValues = showValues;
    [self setNeedsDisplay];
}

- (float)valueFudge
{
    if (_valueFudge == 0.0)
    {
        _valueFudge = (_absMaxVal - _absMinVal) / FUDGE_FACTOR;
    }
    return _valueFudge;
}

- (float)minValSpan
{
    if (_minValSpan == 0.0)
    {
        _minValSpan = (_absMaxVal - _absMinVal) * (KNOB_WIDTH / (self.bounds.size.width - KNOB_WIDTH));
    }
    return _minValSpan;
}

- (void)setup
{
    self.doneSettingUp = NO;
    self.inColor = self.tintColor;
    self.outColor = OUT_COLOR;
    self.valueColor = VALUE_COLOR;
    self.knobStrokeColor = KNOB_STROKE_COLOR;
    self.knobFillColor = KNOB_FILL_COLOR;
    self.backgroundColor = BACKGROUND_COLOR;
    self.absMinVal = ABS_MIN_VAL;
    self.absMaxVal = ABS_MAX_VAL;
    self.curMinVal = CUR_MIN_VAL;
    self.curMaxVal = CUR_MAX_VAL;
    self.reportInteger = NO;
    self.showValues = YES;
    self.continuous = YES;
    self.precision = PRECISION;
    self.currentKnob = NEITHER;
    self.minValSpan = 0;
    self.valueFudge = 0.0;
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(handlePanGesture:)]];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, INTRINSIC_HEIGHT);
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    self.doneSettingUp = YES;
    CGFloat adjustedBoundsWidth = self.bounds.size.width - KNOB_WIDTH;
    float virtualWidth = self.absMaxVal - self.absMinVal;
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        self.panHappening = NO;
    }
    if (gesture.state == UIGestureRecognizerStateChanged || (!self.continuous && gesture.state == UIGestureRecognizerStateEnded))
    {
        CGPoint translation = [gesture translationInView:self];
        [gesture setTranslation:CGPointZero inView:self];
        float newKnobVal = self.currentKnob == LEFT_KNOB ? self.curMinVal : self.curMaxVal;
        float deltaPercentage = translation.x / adjustedBoundsWidth;
        newKnobVal += deltaPercentage * virtualWidth;
        if (self.currentKnob == LEFT_KNOB)
        {
            if (newKnobVal >= self.absMinVal &&
                (newKnobVal < self.curMinVal || newKnobVal < self.curMaxVal - self.minValSpan))
            {
                if (fabsf(newKnobVal - self.absMinVal) > self.valueFudge)
                {
                    self.curMinVal = newKnobVal;
                }
                else
                {
                    self.curMinVal = self.absMinVal;
                }
            }
        }
        else
        {
            if (newKnobVal <= self.absMaxVal &&
                (newKnobVal > self.curMaxVal || newKnobVal > self.curMinVal + self.minValSpan))
            {
                if (fabsf(newKnobVal - self.absMaxVal) > self.valueFudge)
                {
                    self.curMaxVal = newKnobVal;
                }
                else
                {
                    self.curMaxVal = self.absMaxVal;
                }
            }
        }
    }
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGFloat firstX = ((self.curMinVal - self.absMinVal) / virtualWidth) * adjustedBoundsWidth + KNOB_WIDTH / 2;
        CGFloat secondX = ((self.curMaxVal - self.absMinVal) / virtualWidth) * adjustedBoundsWidth + KNOB_WIDTH / 2;
        CGFloat gestureX = [gesture locationInView:self].x;
        float distFirst = ABS(gestureX - firstX);
        float distSecond = ABS(gestureX - secondX);
        if (distFirst < distSecond)
        {
            self.currentKnob = LEFT_KNOB;
        }
        else
        {
            self.currentKnob = RIGHT_KNOB;
        }
        self.panHappening = YES;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat adjustedBoundsWidth = self.bounds.size.width - KNOB_WIDTH;
    CGFloat halfBoundsHeight = self.bounds.size.height / 2;
    float virtualWidth = self.absMaxVal - self.absMinVal;
    float offsetCurMinVal = self.curMinVal - self.absMinVal;
    float offsetCurMaxVal = self.curMaxVal - self.absMinVal;
    CGFloat firstX = (offsetCurMinVal / virtualWidth) * adjustedBoundsWidth + KNOB_WIDTH / 2;
    CGFloat secondX = (offsetCurMaxVal / virtualWidth) * adjustedBoundsWidth + KNOB_WIDTH / 2;
    UIBezierPath *leftOutPath = [UIBezierPath new];
    UIBezierPath *inPath = [UIBezierPath new];
    UIBezierPath *rightOutPath = [UIBezierPath new];
    leftOutPath.lineWidth = LINE_WIDTH;
    inPath.lineWidth = LINE_WIDTH;
    rightOutPath.lineWidth = LINE_WIDTH;
    [self.outColor setStroke];
    [leftOutPath moveToPoint:CGPointMake(KNOB_WIDTH / 2, halfBoundsHeight)];
    [leftOutPath addLineToPoint:CGPointMake(firstX, halfBoundsHeight)];
    [leftOutPath closePath];
    [leftOutPath stroke];
    [self.inColor setStroke];
    [inPath moveToPoint:CGPointMake(firstX, halfBoundsHeight)];
    [inPath addLineToPoint:CGPointMake(secondX, halfBoundsHeight)];
    [inPath closePath];
    [inPath stroke];
    [self.outColor setStroke];
    [rightOutPath moveToPoint:CGPointMake(secondX, halfBoundsHeight)];
    [rightOutPath addLineToPoint:CGPointMake(self.bounds.size.width - KNOB_WIDTH / 2, halfBoundsHeight)];
    [rightOutPath closePath];
    [rightOutPath stroke];
    [self drawKnobAtX:firstX value:self.curMinVal halfBoundsHeight:halfBoundsHeight];
    [self drawKnobAtX:secondX value:self.curMaxVal halfBoundsHeight:halfBoundsHeight];
}

- (void)drawKnobAtX:(CGFloat)x value:(float)value halfBoundsHeight:(float)halfBoundsHeight
{
    UIBezierPath *knob = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, halfBoundsHeight)
                                                        radius:(KNOB_WIDTH/2 - 1)
                                                    startAngle:0
                                                      endAngle:2*M_PI
                                                     clockwise:YES];
    knob.lineWidth = KNOB_BORDER_WIDTH;
    [self.knobStrokeColor setStroke];
    [self.knobFillColor setFill];
    [knob stroke];
    [knob fill];
    if (self.showValues)
    {
        NSString *valueString = @"";
        if (self.reportInteger)
        {
            valueString = [NSString stringWithFormat:@"%ld", lroundf(value)];
        }
        else
        {
            NSString *formatString = [NSString stringWithFormat:@"%%.0%df", self.precision];
            valueString = [NSString stringWithFormat:formatString, value];
        }
        CGSize valueSize = [valueString sizeWithAttributes:nil];
        CGFloat valueX = x - valueSize.width / 2;
        if (valueX < 0.0)
        {
            valueX = 0.0;
        }
        else if (valueX + valueSize.width > self.bounds.size.width)
        {
            valueX = self.bounds.size.width - valueSize.width;
        }
        [valueString drawAtPoint:CGPointMake(valueX, halfBoundsHeight + KNOB_WIDTH / 2)
                  withAttributes:@{ NSForegroundColorAttributeName:self.valueColor }];
    }
}
@end
