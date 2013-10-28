//
//  FlickrImageCell.m
//  FlickrTable
//
//  Created by Stefan Burettea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "FlickrImageCell.h"
#import <UIKit/UIKit.h>

@implementation FlickrImageCell
{
    UILabel *_labelTitle;
    UILabel *_labelContent;
    UIImageView *_imageView;
    UIActivityIndicatorView *_activityIndicator;
}

#pragma mark - Initialization & Deallocation

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textAlignment = NSTextAlignmentLeft;
        _labelTitle.font = [UIFont boldSystemFontOfSize:20];
        _labelTitle.backgroundColor = [UIColor clearColor];
        _labelTitle.opaque = NO;

        
        _labelContent = [[UILabel alloc] init];
        _labelContent.textAlignment = NSTextAlignmentRight;
        _labelContent.backgroundColor = [UIColor clearColor];
        _labelContent.opaque = NO;

        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:_labelTitle];
        [self addSubview:_labelContent];
        [self addSubview:_activityIndicator];
	}
	return self;
}



#pragma mark - Public Methods

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)setTitle:(NSString *)_title
{
    _labelTitle.text = _title;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSString *)title
{
    return _labelTitle.text;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)setContent:(NSString *)_title
{
    _labelContent.text = _title;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSString *)content
{
    return _labelContent.text;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)startAnimation
{
    [_activityIndicator startAnimating];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)stopAnimation
{
    [_activityIndicator stopAnimating];
}


// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)setPreviewImage:(UIImage *)_previewImage
{
//    _imageView.image = _previewImage;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (UIImage *)previewImage
{
//    return _imageView.image;
}


#pragma mark - UIView Methods

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: layoutSubviews                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
static const NSUInteger LEFT_RIGHT_MARGINS_OFFSET = 20;
static const NSUInteger TOP_BOTTOM_MARGINS_OFFSET = 1;
static const NSUInteger TITLE_LABEL_WIDTH = 150;
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.frame;
    CGRect frame;
    
    frame = CGRectMake(LEFT_RIGHT_MARGINS_OFFSET, TOP_BOTTOM_MARGINS_OFFSET, TITLE_LABEL_WIDTH, contentRect.size.height - 2*TOP_BOTTOM_MARGINS_OFFSET);
    _labelTitle.frame = frame;
    
    frame = CGRectMake(LEFT_RIGHT_MARGINS_OFFSET + TITLE_LABEL_WIDTH + 1, TOP_BOTTOM_MARGINS_OFFSET, contentRect.size.width - LEFT_RIGHT_MARGINS_OFFSET - TITLE_LABEL_WIDTH - 1 - LEFT_RIGHT_MARGINS_OFFSET, contentRect.size.height - 2*TOP_BOTTOM_MARGINS_OFFSET);
    _labelContent.frame = frame;
}

@end