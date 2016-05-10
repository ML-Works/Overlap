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

@property (readonly, nonatomic) T mainView;
@property (readonly, nonatomic) T overView;
@property (readonly, nonatomic) T bothView;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithGenerator:(T (^)(BOOL isOverlay))generator;

- (void)overlayWithViewFrame:(CGRect)frame;
- (void)overlayWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
