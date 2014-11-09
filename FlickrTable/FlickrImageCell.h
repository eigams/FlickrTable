//
//  FlickrImageCell.h
//  FlickrTable
//
//  Created by Stefan Burettea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrImageCell : UITableViewCell

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) UIImage *previewImage;

- (void) startAnimation;
- (void) stopAnimation;

- (void) setTextColor:(UIColor *)textColor;

@end