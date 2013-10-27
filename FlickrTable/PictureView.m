//
//  PictureView.m
//  FlickrTable
//
//  Created by Stefan Burettea on 29/09/2013.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "PictureView.h"
#import "FlickrConstants.h"

@implementation PictureView
{
    UIImageView *_previewImageView;
    UIActivityIndicatorView *_indicator;
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
static const NSUInteger PICTURE_FRAME = 10;
- (id)initWithFrame:(CGRect)frame picturePreview:(NSString *)previewURL
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        //create and add the imagePreview
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - PICTURE_FRAME, frame.size.height - PICTURE_FRAME)];
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
        
        //send the notification to start downloading the image
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_IMAGE_NOTIFICATION
                                                            object:self
                                                          userInfo:@{@"previewImageView":_previewImageView, @"previewURL": previewURL}];
    }
    
    return self;
}


//- (void)viewWillLayoutSubviews
//{
//    _previewImageView.frame = CGRectMake(5, 60, self.frame.size.width - 10, self.frame.size.height - 10);
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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
    [_previewImageView removeObserver:self forKeyPath:@"image"];
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
