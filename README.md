JFADoubleSlider
===================

`UISlider` is a handy control for selecting a value, but there is no Apple-provided control for selecting a _range_ of values. There are a variety of open-source controls for selecting a range of values, but they must be instantiated and manipulated in code, not using Interface Builder. `JFADoubleSlider`, inspired by `UISlider`, allows the user to select a _range_ of values, integer or non-integer. The developer can instantiate and manipulate `JFADoubleSlider` either in code or, using Xcode’s new IBDesignable/IBInspectable feature, using Interface Builder.

## Demo
To demo `JFADoubleSlider`, clone the repository, double-click `JFADoubleSlider.xcodeproj`, and run on a device or in the simulator. This demo shows both the code and Interface Builder techniques for using `JFADoubleSlider`. Here is a video of the demo: https://vimeo.com/117676693

## Use
Here are the steps to use `JFADoubleSlider` in your app.

1. Add `JFADoubleSlider.h` and `JFADoubleSlider.m` to your project.

2. Import `JFADoubleSlider.h` in your view controller’s .m file.

3. Decide whether you want to instantiate and manipulate `JFADoubleSlider` in code or using Interface Builder. If in code, put code like this in your view controller’s `viewDidLoad:` method. You _must_ specify Auto Layout constraints. The code below, adapted from the demo app, instantiates the slider; sets some properties; instantiates and sets up a label; and pins the `JFADoubleSlider` and the label to the bottom of the view.
```Objective-C
    JFADoubleSlider *programmaticSlider = [[JFADoubleSlider alloc] initWithFrame:self.view.frame];
    programmaticSlider.delegate = self;
    programmaticSlider.absMinVal = -5000.0;
    programmaticSlider.absMaxVal = 5000.0;
    programmaticSlider.curMinVal = -1420.0;
    programmaticSlider.curMaxVal = 1420.0;
    programmaticSlider.reportInteger = YES;
    [self.view addSubview:programmaticSlider];
    UILabel *label = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"Programmatic Double Slider";
    label.font = [UIFont systemFontOfSize:22];
    [label sizeToFit];
    [self.view addSubview:label];
    NSDictionary *viewDict = @{@"slider":programmaticSlider, @"label":label};
    NSArray *vertConstr = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[label][slider]-|" options:0 metrics:nil views:viewDict];
    [self.view addConstraints:vertConstr];
    NSArray *horizConstr = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[slider]-|" options:0 metrics:nil views:viewDict];
    [self.view addConstraints:horizConstr];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
```
If you would like to use Interface Builder, drag a `UIView` into your view; set the height to 62 points and the width to whatever width you want; set the class of the view to JFADoubleSlider; add appropriate constraints; and use the Attributes inspector of the Utilities pane to set any properties whose defaults you don’t want. If you would like to have access to the `JFADoubleSlider` in your view controller, implement <JFADoubleSliderDelegate> in the view controller, create an outlet from the `JFADoubleSlider` to the view controller, set its delegate, and implement any relevant callback methods of `JFADoubleSliderDelegate`. The following video shows all these steps but the last: https://vimeo.com/117679785

The developer regrets the necessity of manually setting the height of `JFADoubleSlider` to 62 points in Interface Builder, but there does not appear to be a way to automatically set an IBDesignable/IBInspectable control’s dimensions using, say, intrinsic content size. By contrast, `UISlider`, for example, starts with an appropriate height when dragged into a view. Indeed, `UISlider`’s height cannot be modified in Interface Builder.

For descriptions of `JFADoubleSlider`’s properties and the control’s protocol, `JFASliderDelegate`, see the comments in `JFADoubleSlider.h`.

## Creator

**Josh Adams**
* [http://www.immigrationapp.biz](http://www.immigrationapp.biz)
* [@vermont42](https://twitter.com/vermont42)

## Credits

Thanks to Jack Cox for his [tutorial](http://captechconsulting.com/blog/jack-cox/ibdesignables-xcode-6-and-ios-8) on IBDesignable/IBInspectable. 

Thanks to [PJ Vea](http://www.veasoftware.com) for reviewing the code.

## License
```
The MIT License (MIT)

Copyright (c) 2015 Josh Adams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```