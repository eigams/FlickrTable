//
//  FlickrImageListViewController.h
//  FlickrTable
//
//  Created by Stefan Buretea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HorizontalScrollerDelegate;
@protocol FlickerImageSourceDelegate;
@protocol ImageInfoHTTPClientDelegate;


@interface FlickrImageListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, HorizontalScrollerDelegate, FlickerImageSourceDelegate>

@end