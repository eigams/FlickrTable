//
//  PictureView.m
//  FlickrTable
//
//  Created by Stefan Burettea on 29/09/2013.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "PictureView.h"
#import "FlickrConstants.h"
#import "UIImageView+AFNetworking.h"

@interface PictureView()
{
    UIImageView *_previewImageView;
    UIActivityIndicatorView *_indicator;
}

@end

@implementation PictureView

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
static const NSUInteger PICTURE_FRAME = 10;
static const NSUInteger PICTURE_ORIGIN_X = 5;
static const NSUInteger PICTURE_ORIGIN_Y = 5;
- (id)initWithFrame:(CGRect)frame picturePreview:(NSString *)previewURL
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        //create and add the imagePreview
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PICTURE_ORIGIN_X, PICTURE_ORIGIN_Y, frame.size.width - PICTURE_FRAME, frame.size.height - PICTURE_FRAME)];
        [self addSubview:_previewImageView];
        
        //create, add and start the activity indicator
        _indicator = [[UIActivityIndicatorView alloc] init];
        _indicator.center = self.center;
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [_indicator startAnimating];
        
        [self addSubview:_indicator];
        
        //add an observer for the image member of the _previewImage
        //when that changes, the image has been downloaded and the activity indicator should stop
        [_previewImageView addObserver:self forKeyPath:@"image" options:0 context:nil];
        
        if(nil != _previewImageView && nil != previewURL)
        {
            //AFNetworking category over UIImageView
            [_previewImageView setImageWithURL:[NSURL URLWithString:previewURL]];
        }
    }
    
    return self;
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
- (void) dealloc
{
    @try
    {
        [_previewImageView removeObserver:self forKeyPath:@"image"];
    }
    @catch (NSException __unused *exception){}
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
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"image"])
    {
        [_indicator stopAnimating];
    }
}

@end
