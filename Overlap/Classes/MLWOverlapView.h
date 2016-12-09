//
//  MLWOverlapView.h
//  Overlap
//
//  Created by Anton Bukov on 10.05.16.
//  Copyright © 2016 MachineLearningWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLWOverlapView <T : UIView *> : UIView

@property (readonly, nonatomic) NSArray<T> *overViews;
- (void)enumerateOverViews:(void(^)(T overView, NSUInteger index))block;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithGenerator:(T (^)(NSUInteger overlapIndex))generator;
- (instancetype)initWithOverlapsCount:(NSUInteger)overlapsCount generator:(UIView * (^)(NSUInteger overlapIndex))generator;

- (void)overlapWithViewPaths:(NSArray<UIBezierPath *> *)frames;
- (void)overlapWithViewFrames:(NSArray<NSValue *> *)frames;
- (void)overlapWithViews:(NSArray<UIView *> *)views;

@end

NS_ASSUME_NONNULL_END
