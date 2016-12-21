//
//  MLWOverlapView.m
//  Overlap
//
//  Created by Anton Bukov on 10.05.16.
//  Copyright © 2016 MachineLearningWorks. All rights reserved.
//

#import "MLWOverlapView.h"

CGRect MLWCGRectMinusCGRect(CGRect fromRect, CGRect toRect) {
    if (CGRectIsEmpty(toRect)) {
        return fromRect;
    }
    
    if (CGRectContainsRect(toRect, fromRect)) {
        return CGRectZero;
    }
    
    BOOL topLeft = CGRectContainsPoint(toRect, CGPointMake(CGRectGetMinX(fromRect),CGRectGetMinY(fromRect)));
    BOOL topRight = CGRectContainsPoint(toRect, CGPointMake(CGRectGetMaxX(fromRect),CGRectGetMinY(fromRect)));
    BOOL bottomLeft = CGRectContainsPoint(toRect, CGPointMake(CGRectGetMinX(fromRect),CGRectGetMaxY(fromRect)));
    BOOL bottomRight = CGRectContainsPoint(toRect, CGPointMake(CGRectGetMaxX(fromRect),CGRectGetMaxY(fromRect)));
    if ((topLeft ? 1 : 0) + (topRight ? 1 : 0) + (bottomLeft ? 1 : 0) + (bottomRight ? 1 : 0) != 2) {
        return CGRectNull;
    }
    
    CGRect result = fromRect;
    if (topLeft && topRight) {
        result.origin.y = CGRectGetMaxY(toRect);
        result.size.height -= (CGRectGetMaxY(toRect) - CGRectGetMinY(fromRect));
    }
    else if (bottomLeft && bottomRight) {
        result.size.height -= (CGRectGetMaxY(fromRect) - CGRectGetMinY(toRect));
    }
    else if (topLeft && bottomLeft) {
        result.origin.x = CGRectGetMaxX(toRect);
        result.size.width -= (CGRectGetMaxX(toRect) - CGRectGetMinX(fromRect));
    }
    else if (topRight && bottomRight) {
        result.size.width -= (CGRectGetMaxX(fromRect) - CGRectGetMinX(toRect));
    }
    else {
        NSCAssert(NO, @"Impossible case");
    }
    
    return result;
}

//

@interface MLWNonTappableView : UIView

@end

@implementation MLWNonTappableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return (view == self) ? nil : view;
}

- (void)layoutSubviews {
    if (self.hidden) {
        return;
    }
    [super layoutSubviews];
}

@end

//

@interface MLWOverlapView ()

@property (strong, nonatomic) NSArray<UIView *> *overViews;
@property (strong, nonatomic) NSArray<UIView *> *waterViews;
@property (strong, nonatomic) NSArray<CAShapeLayer *> *overMasks;
@property (strong, nonatomic) NSArray<UIBezierPath *> *lastPaths;

@end

@implementation MLWOverlapView

- (instancetype)initWithGenerator:(UIView * (^)(NSUInteger overlapIndex))generator {
    return [self initWithOverlapsCount:2 generator:generator];
}

- (instancetype)initWithOverlapsCount:(NSUInteger)overlapsCount generator:(UIView * (^)(NSUInteger overlapIndex))generator {
    self = [super init];
    if (self) {
        NSMutableArray *overMasks = [NSMutableArray array];
        NSMutableArray *waterViews = [NSMutableArray array];
        NSMutableArray *overViews = [NSMutableArray array];
        for (NSInteger index = 0; index < overlapsCount; index++) {
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.rasterizationScale = [UIScreen mainScreen].scale;
            maskLayer.shouldRasterize = YES;
            [overMasks addObject:maskLayer];
            
            UIView *waterView = [[MLWNonTappableView alloc] init];
            waterView.clipsToBounds = YES;
            waterView.layer.mask = maskLayer;
            [self addSubview:waterView];
            waterView.translatesAutoresizingMaskIntoConstraints = NO;
            [waterView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
            [waterView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
            [waterView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
            [waterView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
            [waterViews addObject:waterView];
            
            UIView *overView = generator(index);
            [waterView addSubview:overView];
            overView.translatesAutoresizingMaskIntoConstraints = NO;
            [overView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
            [overView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
            [overView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
            [overView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
            [overViews addObject:overView];
        }
        
        _waterViews = waterViews;
        _overViews = overViews;
        _overMasks = overMasks;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return (view == self) ? nil : view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.lastPaths) {
        [self overlapWithViewPaths:self.lastPaths];
    }
}

- (void)overlapWithViewPaths:(NSArray<UIBezierPath *> *)paths {
    self.lastPaths = paths;
    
    for (NSInteger i = 0; i < paths.count; i++) {
        UIView *waterView = self.waterViews[i];
        UIView *overView = self.overViews[i];
        CAShapeLayer *maskLayer = self.overMasks[i];
        
        if (CGPathIsEmpty(paths[i].CGPath)) {
            if (!waterView.hidden) {
                waterView.hidden = YES;
            }
            continue;
        }
        
        CGRect frame;
        if (CGPathIsRect(paths[i].CGPath, &frame)) {
            if (CGRectIsEmpty(CGRectIntersection(frame, self.bounds))) {
                if (!waterView.hidden) {
                    waterView.hidden = YES;
                }
                continue;
            } else if (waterView.hidden) {
                waterView.hidden = NO;
            }
            
            if (waterView.layer.mask) {
                waterView.layer.mask = nil;
            }
            if (!CGRectEqualToRect(waterView.frame, frame)) {
                waterView.frame = frame;
                overView.transform = CGAffineTransformMakeTranslation(
                    -frame.origin.x,
                    -frame.origin.y
                );
            }
            continue;
        }
        
        if (waterView.hidden) {
            waterView.hidden = NO;
        }
        if (waterView.layer.mask == nil) {
            maskLayer = self.overMasks[i];
            waterView.layer.mask = maskLayer;
            waterView.frame = self.bounds;
            overView.transform = CGAffineTransformIdentity;
        }
        if (!CGPathEqualToPath(maskLayer.path, paths[i].CGPath)) {
            maskLayer.path = paths[i].CGPath;
        }
    }
}

- (void)overlapWithViewFrames:(NSArray<NSValue *> *)frames {
    NSMutableArray<UIBezierPath *> *paths = [NSMutableArray array];
    for (NSValue *value in frames) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:value.CGRectValue];
        [paths addObject:path];
    }
    [self overlapWithViewPaths:paths];
}

- (void)overlapWithViews:(NSArray<UIView *> *)views {
    NSMutableArray<UIBezierPath *> *paths = [NSMutableArray array];
    for (UIView *view in views) {
        CGRect frame = (self.window == view.window) ? [view convertRect:view.bounds toView:self] : CGRectZero;
        [paths addObject:[UIBezierPath bezierPathWithRect:frame]];
    }
    [self overlapWithViewPaths:paths];
}

- (void)enumerateOverViews:(void(^)(UIView *overView, NSUInteger index))block {
    for (NSUInteger i = 0; i < self.overViews.count; i++) {
        block(self.overViews[i], i);
    }
}

@end
