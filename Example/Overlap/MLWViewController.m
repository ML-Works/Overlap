//
//  MLWViewController.m
//  Overlap
//
//  Created by Anton Bukov on 05/10/2016.
//  Copyright (c) 2016 Anton Bukov. All rights reserved.
//

#import <Overlap/Overlap.h>

#import "MLWViewController.h"

@interface MLWViewController ()

@property (strong, nonatomic) UIView *redView;
@property (strong, nonatomic) UILabel *panMeLabel;
@property (strong, nonatomic) MLWOverlapView *overlapView;

@end

@implementation MLWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.redView = [[UIView alloc] init];
    self.redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.redView];
    self.redView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.redView.heightAnchor constraintEqualToConstant:100].active = YES;
    [self.redView.widthAnchor constraintEqualToConstant:100].active = YES;
    [self.redView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.redView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:100].active = YES;

    self.panMeLabel = [[UILabel alloc] init];
    self.panMeLabel.text = @"Pan me!";
    self.panMeLabel.textColor = [UIColor whiteColor];
    [self.redView addSubview:self.panMeLabel];
    self.panMeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.panMeLabel.bottomAnchor constraintEqualToAnchor:self.redView.bottomAnchor].active = YES;
    [self.panMeLabel.centerXAnchor constraintEqualToAnchor:self.redView.centerXAnchor].active = YES;

    self.overlapView = [[MLWOverlapView alloc] initWithGenerator:^UIView *(BOOL isOverlay) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Some cool text";
        label.font = [UIFont boldSystemFontOfSize:32.0];
        label.textColor = isOverlay ? [UIColor whiteColor] : [UIColor redColor];
        return label;
    }];
    [self.view addSubview:self.overlapView];
    self.overlapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.overlapView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.overlapView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:self.view];

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.panMeLabel.alpha = 1.0 - MIN(1.0, (point.x * point.x + point.y * point.y) / 100.0);
        self.redView.transform = CGAffineTransformMakeTranslation(point.x, point.y);
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.panMeLabel.alpha = 1.0;
        self.redView.transform = CGAffineTransformIdentity;
    }

    [self.overlapView overlapWithView:self.redView];
}

@end
