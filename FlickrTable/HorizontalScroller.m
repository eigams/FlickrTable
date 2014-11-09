//
//  HorizontalScroller.m
//  FlickrTable
//
//  Created by Stefan Buretea.
//  Inspired by http://www.raywenderlich.com/46988/ios-design-patterns
//  Copyright (c) 2013 Eli Ganem. All rights reserved.
//

#import "HorizontalScroller.h"

static const NSInteger VIEW_PADDING_X = 10;
static const NSInteger VIEW_PADDING_Y = 40;
static const NSInteger VIEW_DIMENSIONS_WIDTH = 230;
static const NSInteger VIEW_DIMENSIONS_HEIGHT = 230;
static const NSInteger VIEW_OFFSET = 10;

@interface HorizontalScroller() <UIScrollViewDelegate>
{
    UIScrollView *_scroller;
}

@end

@implementation HorizontalScroller

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
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scroller.delegate = self;
        
        [self addSubview:_scroller];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        
        //stops tapRecognizer to override doubleTapRecognizer
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        
        [_scroller addGestureRecognizer:tapRecognizer];
        [_scroller addGestureRecognizer:doubleTapRecognizer];
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
typedef void (^HorizontalScrollerClickedViewDelegateMethod_t) (int index);
- (void)gestureRecognizerAction:(UITapGestureRecognizer *)gesture withDelegate:(HorizontalScrollerClickedViewDelegateMethod_t)delegate
{
    CGPoint location = [gesture locationInView:gesture.view];
    
    for(int index = 0;index < [self.delegate numberOfViewsForHorizontalScroller:self]; ++index)
    {
        UIView *view = _scroller.subviews[index];
        if(CGRectContainsPoint(view.frame, location))
        {
            delegate(index);

            [_scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0) animated:YES];
            
            break;
        }
    }
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:    animateViewAtIndex                               |+|
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
- (void)animateViewFrameAtIndex:(NSUInteger)index {
    
    if(index >= [_scroller.subviews count]) {
        return ;
    }
    
    UIView *view = _scroller.subviews[index];
    UIColor *saveColor = view.backgroundColor;
    view.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:1.5 animations:^{
        view.backgroundColor = saveColor;
    }];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:    scrollerTapped                                   |+|
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
- (void)scrollerTapped:(UITapGestureRecognizer *)gesture
{
    [self gestureRecognizerAction:gesture withDelegate:^(int index) {
        [self.delegate horizontalScroller:self clickedViewAtIndex:index];
       
        [self animateViewFrameAtIndex:index];
    }];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   scrollerDoubleTapped                              |+|
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
- (void)scrollerDoubleTapped:(UITapGestureRecognizer *)gesture
{
    [self gestureRecognizerAction:gesture withDelegate:^(int index) {
        [self.delegate horizontalScroller:self doubleClickedViewAtIndex:index];
    }];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   reload                                            |+|
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
- (void)reload
{
    if(nil == self.delegate) {
        return;
    }
    
    //remove all subviews
    [_scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    CGFloat xValue = VIEW_OFFSET;
    for(int i = 0; i < [self.delegate numberOfViewsForHorizontalScroller:self]; ++i) {
        
        xValue += VIEW_PADDING_X;
        UIView *view = [self.delegate horizontalScroller:self viewAtIndex:i];
        view.frame = CGRectMake(xValue, VIEW_PADDING_Y, VIEW_DIMENSIONS_WIDTH, VIEW_DIMENSIONS_HEIGHT);
        
        [_scroller addSubview:view];
        xValue += VIEW_DIMENSIONS_WIDTH + VIEW_PADDING_X;
    }
    
    [_scroller setContentSize:CGSizeMake(xValue + VIEW_OFFSET, self.frame.size.height)];
    
    //if an initial view is defined, center the scroller on it
    if([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)]) {
        int initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        [_scroller setContentOffset:CGPointMake(initialView*(VIEW_DIMENSIONS_WIDTH + (2*VIEW_PADDING_X)), 0) animated:YES];
    }
    
    if([self.delegate respondsToSelector:@selector(viewIndexForHorizontalScroller:)]) {
        int viewIndex = [self.delegate viewIndexForHorizontalScroller:self];

        [_scroller setContentOffset:CGPointMake(viewIndex*(VIEW_DIMENSIONS_WIDTH + (2*VIEW_PADDING_X)), 0) animated:YES];
        
        [self animateViewFrameAtIndex:viewIndex + 1];
    }
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
- (void) didMoveToSuperview
{
    [self reload];
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
- (void)centerCurrentView
{
    int xFinal = _scroller.contentOffset.x + (VIEW_OFFSET/2) + VIEW_PADDING_Y;
    int viewIndex = xFinal / (VIEW_DIMENSIONS_WIDTH + (2*VIEW_PADDING_X));
    
    xFinal = viewIndex * (VIEW_DIMENSIONS_WIDTH + (2*VIEW_PADDING_X));
    [_scroller setContentOffset:CGPointMake(xFinal,0) animated:YES];
    
    [self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex + 1];
    
    [self animateViewFrameAtIndex:viewIndex + 1];
}

#pragma mark - UIViewScrollDelegate callbacks

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  scrollViewDidEndDragging                           |+|
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
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self centerCurrentView];
    }
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   scrollViewDidEndDecelerating                      |+|
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
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}


@end
