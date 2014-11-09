//
//  CenteredScrollView.h
//  FlickrTable
//
//  Created by Stefan Buretea on 2/12/14.
//  Copyright (c) 2014 NumberFour AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CenteredScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;

- (void)addImageView:(UIImageView *)imageView;

@end
