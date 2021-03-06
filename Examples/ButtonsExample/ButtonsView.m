//
//  View.m
//  ButtonsExample
//
//  Created by Eric Horacek on 12/27/14.
//  Copyright (c) 2014 Automatic Labs, Inc. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "ButtonsView.h"

@interface ButtonsView ()

@property (nonatomic) UIButton *saveButton;
@property (nonatomic) UIButton *deleteButton;

@end

@implementation ButtonsView

#pragma mark - UIView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

static CGFloat const ButtonWidth = 145.0;
static CGFloat const ButtonPadding = 10.0;

- (void)updateConstraints {
    [super updateConstraints];
        
    [self.saveButton
        mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self.mas_centerX).offset(-(ButtonPadding / 2.0));
            make.width.equalTo(@(ButtonWidth));
        }];
    
    [self.deleteButton
        mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX).offset((ButtonPadding / 2.0));
            make.centerY.equalTo(self.saveButton);
            make.width.equalTo(@(ButtonWidth));
        }];
}

#pragma mark - ButtonsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [self addSubview:self.deleteButton];
        [self addSubview:self.saveButton];
    }
    return self;
}

@end
