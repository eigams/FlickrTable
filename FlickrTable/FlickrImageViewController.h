//
//  FlickrImageViewController.h
//  FlickrTable
//
//  Created by Stefan Buretea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrImage;

@interface FlickrImageViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

- (id)initWithFlickrImage:(FlickrImage *)image;

@end