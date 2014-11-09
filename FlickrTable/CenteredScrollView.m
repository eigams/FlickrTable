//
//  CenteredScrollView.m
//  FlickrTable
//
//  Created by Stefan Buretea on 2/12/14.
//  Copyright (c) 2014 AG. All rights reserved.
//

#import "CenteredScrollView.h"
#import <QuartzCore/QuartzCore.h>

@interface CenteredScrollView ()
    @property (nonatomic, strong) UIImageView *imageView;
@end

@implementation CenteredScrollView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.delegate = self;
        
        self.maximumZoomScale = 20;
        
//        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 900)];
        self.containerView = [[UIView alloc] initWithFrame:frame];
//        self.containerView.backgroundColor = [UIColor blueColor];
        self.containerView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.containerView.layer.borderWidth = 2.f;
        
        [self addSubview:self.containerView];
        self.contentSize = self.containerView.frame.size;
        
//        self.testView = [[UIView alloc] initWithFrame:CGRectMake(270, 170, 50, 50)];
//        self.imageView = [[UIImageView alloc] initWithFrame:frame];
//        self.imageView.backgroundColor = [UIColor greenColor];
//        [self.containerView addSubview:self.imageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
        tapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)addImageView:(UIImageView *)imageView
{
    self.imageView = imageView;

    [self.containerView addSubview:self.imageView];
}

- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated
{
    NSLog(@"In zoom point !!!");
    
    //Normalize current content size back to content scale of 1.0f
    CGSize contentSize;
    contentSize.width = (self.contentSize.width / self.zoomScale);
    contentSize.height = (self.contentSize.height / self.zoomScale);
    
    //translate the zoom point to relative to the content rect
    zoomPoint.x = (zoomPoint.x / self.bounds.size.width) * contentSize.width;
    zoomPoint.y = (zoomPoint.y / self.bounds.size.height) * contentSize.height;
    
    //derive the size of the region to zoom to
    CGSize zoomSize;
    zoomSize.width = self.bounds.size.width / scale;
    zoomSize.height = self.bounds.size.height / scale;
    
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    CGRect zoomRect;
    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
    zoomRect.size.width = zoomSize.width;
    zoomRect.size.height = zoomSize.height;
    
    //apply the resize
    [self zoomToRect: zoomRect animated: animated];
}


- (void)doubleTapped:(UITapGestureRecognizer *)tapGesture
{
    if(self.zoomScale == 1)
    {
        CGPoint pointInView = [tapGesture locationInView:self.imageView];
        
        //[self zoomToRect:CGRectInset(self.imageView.frame, -1, -1) animated:YES];
        [self zoomToPoint:pointInView withScale:self.zoomScale animated:YES];
    }
    else
    {
        [self setZoomScale:1 animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

- (void)centerContent
{
    CGFloat top = 0, left = 0;
    
    if (self.contentSize.width < self.bounds.size.width)
    {
        left = (self.bounds.size.width-self.contentSize.width) * 0.5f;
    }
    
    if (self.contentSize.height < self.bounds.size.height)
    {
        top = (self.bounds.size.height-self.contentSize.height) * 0.5f;
    }
    
    self.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

- (void)scrollViewDidZoom:(__unused UIScrollView *)scrollView
{
    [self centerContent];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self centerContent];
}

@end
