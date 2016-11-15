//
//  MLWOverlapView.m
//  Overlap
//
//  Created by Anton Bukov on 10.05.16.
//  Copyright © 2016 MachineLearningWorks. All rights reserved.
//

#import "MLWOverlapView.h"

@interface MLWMultiProxy : NSProxy

@property (copy, nonatomic) NSArray *objects;

@end

@implementation MLWMultiProxy

- (instancetype)initWithObjects:(NSArray *)objects {
    self.objects = objects;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.objects.firstObject methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    for (NSObject *object in self.objects) {
        [invocation invokeWithTarget:object];
    }
}

@end

@interface MLWNonTappableView : UIView

@end

@implementation MLWNonTappableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return (view == self) ? nil : view;
}

@end

//

@interface MLWOverlapView ()

@property (strong, nonatomic) UIView *mainView;
@property (copy, nonatomic) NSArray<UIView *> *overViews;
@property (copy, nonatomic) NSArray<UIView *> *waterViews;
@property (copy, nonatomic) NSArray<NSValue *> *waterFrames;

@end

@implementation MLWOverlapView

- (instancetype)initWithGenerator:(UIView * (^)(NSUInteger overlapIndex))generator {
    return [self initWithOverlapsCount:1 generator:generator];
}

- (instancetype)initWithOverlapsCount:(NSUInteger)overlapsCount generator:(UIView * (^)(NSUInteger overlapIndex))generator {
    self = [super init];
    if (self) {
        UIView *mainView = generator(0);
        [self addSubview:mainView];
        mainView.translatesAutoresizingMaskIntoConstraints = NO;

        NSMutableArray *overViews = [NSMutableArray arrayWithCapacity:overlapsCount];
        NSMutableArray *waterViews = [NSMutableArray arrayWithCapacity:overlapsCount];
        for (NSInteger index = 1; index <= overlapsCount; index++) {
            UIView *overView = generator(index);
            [overViews addObject:overView];

            UIView *waterView = [[MLWNonTappableView alloc] initWithFrame:self.bounds];
            waterView.backgroundColor = [UIColor clearColor];
            waterView.clipsToBounds = YES;
            [waterViews addObject:waterView];

            [self addSubview:waterView];
            [waterView addSubview:overView];
            waterView.translatesAutoresizingMaskIntoConstraints = NO;
            overView.translatesAutoresizingMaskIntoConstraints = NO;

            [overView.topAnchor constraintEqualToAnchor:waterView.topAnchor].active = YES;
            [overView.leadingAnchor constraintEqualToAnchor:waterView.leadingAnchor].active = YES;
            [overView.widthAnchor constraintEqualToAnchor:mainView.widthAnchor].active = YES;
            [overView.heightAnchor constraintEqualToAnchor:mainView.heightAnchor].active = YES;
        }

        _mainView = mainView;
        _overViews = overViews;
        _waterViews = waterViews;

        [mainView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [mainView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [mainView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [mainView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return (view == self) ? nil : view;
}

- (UIView *)entireOverView {
    return (id)[[MLWMultiProxy alloc] initWithObjects:self.overViews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self letsLayout];
}

- (void)letsLayout {
    for (NSInteger i = 0; i < self.waterViews.count; i++) {
        CGRect frame = self.waterFrames[i].CGRectValue;
        self.waterViews[i].frame = frame;
        UIView *overView = self.overViews[i];
        overView.transform = CGAffineTransformMakeTranslation(-frame.origin.x, -frame.origin.y);
    }
}

- (void)overlapWithViewFrames:(NSArray<NSValue *> *)frames {
    self.waterFrames = frames;
    [self letsLayout];
}

- (void)overlapWithViews:(NSArray<UIView *> *)views {
    NSMutableArray *frames = [NSMutableArray array];
    for (UIView *view in views) {
        CGRect frame = (self.window == view.window) ? [view convertRect:view.bounds toView:self] : CGRectZero;
        [frames addObject:[NSValue valueWithCGRect:frame]];
    }
    [self overlapWithViewFrames:frames];
}

- (void)enumerateOverViews:(void(^)(UIView *overView))block {
    for (UIView *overView in self.overViews) {
        block(overView);
    }
}

@end
