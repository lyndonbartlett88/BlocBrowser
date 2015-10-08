//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Lyndon Bartlett on 10/5/15.
//  Copyright © 2015 Lyndon Bartlett. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UIButton *currentButton;
//@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar


//-(void) tapFired:(UITapGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//        CGPoint location = [recognizer locationInView:self];
//        UIView *tappedView = [self hitTest:location withEvent:nil];
//        
//        if ([self.labels containsObject:tappedView]) {
//            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
//            }
//        }
//    }
//}
//
//-(void) panFired:(UIPanGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [recognizer translationInView:self];
//        
//        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
//        
//        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
//            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
//        }
//        [recognizer setTranslation:CGPointZero inView:self];
//    }
//}

- (UIColor *)randomColor {
    CGFloat red = arc4random_uniform(256)/256.0;
    CGFloat green = arc4random_uniform(256)/256.0;
    CGFloat blue = arc4random_uniform(256)/256.0;
    UIColor *color = [ UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    NSLog(@"%@", color);
    return color;
}

- (instancetype) initWithFourTitles:(NSArray *)titles{
self = [super init];
    
    if (self) {
        
        self.currentTitles = titles;
//        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
//                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
//                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
//                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *btn = [[UIButton alloc] init];
            btn.userInteractionEnabled = NO;
            btn.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = self.randomColor;
            
            [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
            btn.titleLabel.font = [UIFont systemFontOfSize:10];
            [btn setTitle:titleForThisLabel forState:UIControlStateNormal];
            btn.backgroundColor = colorForThisLabel;
            [btn setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
            
//            label.textAlignment = NSTextAlignmentCenter;
//            label.font = [UIFont systemFontOfSize:10];
//            label.text = titleForThisLabel;
//            label.backgroundColor = colorForThisLabel;
//            label.textColor = [UIColor whiteColor];
            
            [btn addTarget:self action:@selector(clicked_btn:) forControlEvents:UIControlEventTouchUpInside];
            [buttonsArray addObject:btn];
        }
        
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
    

        
        //self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressFired:)];
        //[self addGestureRecognizer:self.tapGesture];
        [self addGestureRecognizer:self.longPressGesture];
    }

    
    return self;
}



- (void) clicked_btn:(id)sender
{
    UIButton* btn = sender;
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:btn.titleLabel.text];
    }
}

//-(void) tapFired:(UITapGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//        CGPoint location = [recognizer locationInView:self];
//        UIView *tappedView = [self hitTest:location withEvent:nil];
//        
//        if ([self.labels containsObject:tappedView]) {
//            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
//            }
//        }
//    }
//}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [recognizer scale];
    
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:scale];
        }
    }
}

- (void) pressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        for (UIButton * currBtn in self.buttons) {
            currBtn.backgroundColor = [self randomColor];
        }
    }
    
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *currBtn in self.buttons) {
        NSUInteger currentLabelIndex = [self.buttons indexOfObject:currBtn];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        currBtn.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark - Touch Handling

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UILabel *)subview;
    } else {
        return nil;
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.currentButton.alpha = 1;
    self.currentButton = nil;
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *btn = [self.buttons objectAtIndex:index];
        btn.userInteractionEnabled = enabled;
        btn.alpha = enabled ? 1.0 : 0.25;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
