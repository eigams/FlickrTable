//
//  HorizontalScroller.h
//  FlickrTable
//
//  Created by Stefan Burettea on 29/09/2013.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HorizontalScrollerDelegate;

@interface HorizontalScroller : UIView

@property (weak) id<HorizontalScrollerDelegate> delegate;

- (void)reload;

@end



@protocol HorizontalScrollerDelegate <NSObject>

@required

//ask the delegate how many views he wants to present inside the horizontal scroller
- (NSInteger) numberOfViewsForHorizontalScroller:(HorizontalScroller *)scroller;

//ask the delegate to return the view that should appear at <index>
- (UIView *)horizontalScroller:(HorizontalScroller *)scroller viewAtIndex:(NSInteger)index;

//inform the delegate that the view at <index> has been clicked
- (void) horizontalScroller:(HorizontalScroller *)scroller clickedViewAtIndex:(NSInteger)index;

//inform the delegate that the view at <index> has been clicked
- (void) horizontalScroller:(HorizontalScroller *)scroller doubleClickedViewAtIndex:(NSInteger)index;

@optional

//ask the delegate for the initial index of the view to display
//defaults to 0 if it's not implemented by the delegate
- (NSInteger) initialViewIndexForHorizontalScroller:(HorizontalScroller *)scroller;

- (NSInteger) viewIndexForHorizontalScroller:(HorizontalScroller *)scroller;

@end
