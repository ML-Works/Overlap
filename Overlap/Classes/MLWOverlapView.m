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

//

@interface MLWOverlapView ()

@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UIView *overView;
@property (strong, nonatomic) UIView *waterView;
@property (assign, nonatomic) CGRect waterFrame;

@end

@implementation MLWOverlapView

- (instancetype)initWithGenerator:(UIView * (^)(BOOL isOverlay))generator {
    self = [super init];
    if (self) {
        UIView *mainView = generator(NO);
        UIView *overView = generator(YES);

        _mainView = mainView;
        _overView = overView;

        UIView *waterView = [[UIView alloc] initWithFrame:self.bounds];
        waterView.backgroundColor = [UIColor clearColor];
        waterView.clipsToBounds = YES;
        _waterView = waterView;

        [self addSubview:mainView];
        [self addSubview:waterView];
        [waterView addSubview:overView];

        mainView.translatesAutoresizingMaskIntoConstraints = NO;
        waterView.translatesAutoresizingMaskIntoConstraints = NO;
        overView.translatesAutoresizingMaskIntoConstraints = NO;

        [mainView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [mainView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [mainView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [mainView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;

        [overView.topAnchor constraintEqualToAnchor:waterView.topAnchor].active = YES;
        [overView.leadingAnchor constraintEqualToAnchor:waterView.leadingAnchor].active = YES;
        [overView.widthAnchor constraintEqualToAnchor:mainView.widthAnchor].active = YES;
        [overView.heightAnchor constraintEqualToAnchor:mainView.heightAnchor].active = YES;
    }
    return self;
}

- (UIView *)bothView {
    return (id)[[MLWMultiProxy alloc] initWithObjects:@[
        self.mainView,
        self.overView,
    ]];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.waterView.frame = self.waterFrame;
    self.overView.transform = CGAffineTransformMakeTranslation(-self.waterFrame.origin.x, -self.waterFrame.origin.y);
}

- (void)overlapWithViewFrame:(CGRect)frame {
    self.waterFrame = frame;
    [self setNeedsLayout];
}

- (void)overlapWithView:(UIView *)view {
    [self overlapWithViewFrame:(self.window == view.window ? [view convertRect:view.bounds toView:self] : CGRectZero)];
}

@end
