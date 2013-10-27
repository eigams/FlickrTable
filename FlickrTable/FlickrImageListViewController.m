//
//  FlickrImageListViewController.m
//  FlickrTable
//
//  Created by Stefan Buretea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "FlickrImageListViewController.h"

#import "FlickrConstants.h"
#import "FlickerImageSource.h"
#import "FlickrImageCell.h"
#import "FlickrImageViewController.h"
#import "FlickrImage.h"
#import "FlickrImage+TableRepresentation.h"

#import "HorizontalScroller.h"
#import "PictureView.h"
#import "LibraryAPI.h"
#import "ImageInfoDelegate.h"

@implementation FlickrImageListViewController
{
    UITableView *_dataTable;
    
    FlickerImageSource *_imageSource;
    
    NSDictionary *_currentPictureData;
    int _currentPictureIndex;
    
    HorizontalScroller *_scroller;
    
    LibraryAPI *_libraryAPI;
    
    UIToolbar *_toolbar;
    
    ImageInfoDelegate *_imageInfoDelegate;
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
- (id)init
{
    self = [super init];
    if(self)
    {
        self.title = @"Recent Photos";
        
        _libraryAPI = [LibraryAPI sharedInstance];
        _imageInfoDelegate = [[ImageInfoDelegate alloc] init];        
    }
    
    return self;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  createDataTable                                    |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:  creates the table that will display the image info   |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:   none                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE: none                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
static const NSUInteger DATATABLE_XPOS = 100;
static const NSUInteger DATATABLE_YPOS = 370;
static const NSUInteger DATATABLE_HEIGHT = 560;
- (void)createDataTable
{
    //create the data table that's gonna hold the picture's details
    _dataTable = [[UITableView alloc] initWithFrame:CGRectMake(DATATABLE_XPOS, DATATABLE_YPOS, self.view.frame.size.width - 200, DATATABLE_HEIGHT) style:UITableViewStyleGrouped];
    _dataTable.delegate = self;
    _dataTable.dataSource = self;
    _dataTable.backgroundColor = [UIColor clearColor];
    _dataTable.opaque = NO;
    _dataTable.backgroundView = nil;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  createToolbar                                      |+|
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
- (void)createToolbar
{
    _toolbar = [[UIToolbar alloc] init];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *rew = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(showPreviousImage)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(imageZoomIn)];
    UIBarButtonItem *fwd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(showNextImage)];
    
    [_toolbar setItems:@[rew, space, play, space, fwd]];
    
    [self.view addSubview:_toolbar];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  showNextImage                                      |+|
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
- (void) showNextImage
{
    if(_currentPictureIndex >= MAX_IMAGES - 1)
    {
        return ;
    }
    
    if(_currentPictureIndex < MAX_IMAGES - 1)
        ++_currentPictureIndex;
    
    [self reloadScroller];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  showPreviousImage                                  |+|
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
- (void) showPreviousImage
{
    if(_currentPictureIndex <= 0)
    {
        return ;
    }
    
    if(_currentPictureIndex > 0)
        --_currentPictureIndex;
    
    [self reloadScroller];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  showZoomedImage                                    |+|
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
- (void) imageZoomIn
{
    [self horizontalScroller:_scroller doubleClickedViewAtIndex:_currentPictureIndex];
    
    [self reloadScroller];
}


// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  viewDidLoad                                        |+|
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
//main function
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentPictureIndex = 0;
    
    //create the uitable that will display the image info
    [self createDataTable];
    
    [self.view addSubview:_dataTable];
    
    _dataTable.rowHeight = 60.0f;
    [_dataTable registerClass:[FlickrImageCell class] forCellReuseIdentifier:NSStringFromClass([FlickrImageCell class])];

    [self createToolbar];
    
    _imageSource = [FlickerImageSource new];
    
    [self updatePhotos:nil];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  viewWillAppear                                     |+|
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
- (void)viewWillAppear:(BOOL)animated
{
    [_scroller reload]; //refresh the scroller when returning to the main view
}

// |+|========================================================================|+|
// |+|                                                                        |+|
// |+|    FUNCTION NAME:  updatePhotos                                        |+|
// |+|                                                                        |+|
// |+|                                                                        |+|
// |+|    DESCRIPTION:   it triggers an update of the current displayed pics  |+|
// |+|                                                                        |+|
// |+|                                                                        |+|
// |+|    PARAMETERS:                                                         |+|
// |+|                                                                        |+|
// |+|                                                                        |+|
// |+|                                                                        |+|
// |+|    RETURN VALUE:                                                       |+|
// |+|                                                                        |+|
// |+|                                                                        |+|
// |+|========================================================================|+|
static const NSUInteger ACTIVITY_INDICATOR_WIDTH = 14;
static const NSUInteger ACTIVITY_INDICATOR_HEIGHT = 14;
static const NSUInteger SCROLLER_Y_POS = 100;
static const NSUInteger SCROLLER_HEIGHT = 310;
- (void)updatePhotos:(id)sender
{
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, ACTIVITY_INDICATOR_WIDTH, ACTIVITY_INDICATOR_HEIGHT)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];

    [activityView startAnimating];
    
    [_imageSource fetchRecentImagesWithCompletion:^{

        @try
        {
            [_libraryAPI clearCache];
            
            _currentPictureIndex = 0;
            
            [self showDataForPictureAtIndex:_currentPictureIndex];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updatePhotos:)];
            
            //create and add the scroller to the scene
            _scroller = [[HorizontalScroller alloc] initWithFrame:CGRectMake(0, SCROLLER_Y_POS, self.view.frame.size.width, SCROLLER_HEIGHT)];
            _scroller.backgroundColor = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
            _scroller.delegate = self;
            [self.view addSubview:_scroller];
            
            [self reloadScroller];
        }
        @catch(NSException *e)
        {
            NSLog(@"Exception caught: %@", e);
        }
        
        [activityView stopAnimating];
    }];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: showDataForPictureAtIndex                           |+|
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
- (void) showDataForPictureAtIndex:(int)pictureIndex
{
    _currentPictureData = nil;
    
    [_dataTable reloadData];
    
    //check for an overstepping index
    if(pictureIndex >= _imageSource.count)
    {
        return ;
    }
    
    FlickrImage *flickrImage = [_imageSource imageAtIndex:pictureIndex];
    
    //if there's an info request in progress
    //cancel it and start the new request
    if(nil != _imageInfoDelegate)
    {
        [_imageInfoDelegate cancelAllCalls];
    }
    
    //start the download of image infos <----> this might take awhile
    [_imageInfoDelegate downloadImageInfo:flickrImage.pid withCompletion:^(NSData *data) {
        
        NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *owner = jsonData[@"photo"][@"owner"];
        NSDictionary *description = jsonData[@"photo"][@"description"];
        NSDictionary *dates = jsonData[@"photo"][@"dates"];
        
        //this will be the image to hold the complete data
        FlickrImage *complete = [FlickrImage imageWithImage:flickrImage];
        
        complete.username = owner[@"username"] ? owner[@"username"] : @"";
        complete.realname = owner[@"realname"] ? owner[@"realname"] : @"";
        complete.location = owner[@"location"] ? owner[@"location"] : @"";
        complete.description = description[@"_content"] ? description[@"_content"] : @"";
        complete.posted = dates[@"posted"] ? dates[@"posted"] : @"";
        complete.taken = dates[@"taken"] ? dates[@"taken"] : @"";

        _currentPictureData = [complete tr_tableRepresentation];

        [_dataTable reloadData];
    }
    failure:^(NSError *error){
        NSLog(@"Error occured: %@", error);
    }];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: reloadScroller                                      |+|
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
- (void)reloadScroller
{
    if(_currentPictureIndex < 0)
    {
        _currentPictureIndex = 0;
    }
    else
    {
        if (_currentPictureIndex >= _imageSource.count)
            _currentPictureIndex = _imageSource.count - 1;
    }
    
    [self showDataForPictureAtIndex:_currentPictureIndex];
    
    [_scroller reload];    
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: reloadScroller                                      |+|
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
- (void)viewWillLayoutSubviews
{
    _scroller.frame = CGRectMake(0, SCROLLER_Y_POS, self.view.frame.size.width, SCROLLER_HEIGHT);
    _toolbar.frame = CGRectMake(0, self.view.frame.size.height - 74, self.view.frame.size.width, 74);
    _dataTable.frame = CGRectMake(DATATABLE_XPOS, DATATABLE_YPOS, self.view.frame.size.width - 200, DATATABLE_HEIGHT);
}

#pragma mark - UITableView DataSource/Delegate methods

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: tableView: cellForRowAtIndexPath:                   |+|
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
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FlickrImageCell *cell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([FlickrImageCell class])];
    
    if(nil == _currentPictureData)
    {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(0, 0, ACTIVITY_INDICATOR_WIDTH, ACTIVITY_INDICATOR_HEIGHT);
        
        cell.accessoryView = spinner;

        [spinner startAnimating];
        
        //create a bogus empty image so we get the title for each row
        FlickrImage *emptyImage = [[FlickrImage alloc] init];
        
        cell.title = [emptyImage tr_tableRepresentation][@"titles"][indexPath.row];
        cell.content = @"";
    }
    else
    {
        cell.title = _currentPictureData[@"titles"][indexPath.row];
        cell.content = _currentPictureData[@"values"][indexPath.row];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)cell.accessoryView;
        [spinner stopAnimating];
        
        cell.accessoryView = nil;
    }

	return cell;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  tableView: numberOfRowsInSection                   |+|
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
static const NSUInteger TABLE_VIEW_ROWS_COUNT = 7;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TABLE_VIEW_ROWS_COUNT;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  tableView: didSelectRowAtIndexPath                 |+|
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
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // show the selected image in our image view controller
//#warning presenting this causes a delay and the app hangs, maybe we can fix it?
//	FlickrImageViewController *ctrl = [[FlickrImageViewController alloc] initWithFlickrImage:[_imageSource imageAtIndex:indexPath.row]];
//
//    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
//    [selectedCell setAccessoryType:(([selectedCell accessoryType] == UITableViewCellAccessoryNone) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
//
//    [self.navigationController pushViewController:ctrl animated:YES];
//}

#pragma mark - HorizontalScrollerDelegate methods

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: horizontalScroller: clickedViewAtIndex              |+|
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
- (void)horizontalScroller:(HorizontalScroller *)scroller clickedViewAtIndex:(int)index
{
    _currentPictureIndex = index;
    
    [self showDataForPictureAtIndex:index];
    
    NSLog(@"_currentPictureIndex: %d", _currentPictureIndex);
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: horizontalScroller: doubleClickedViewAtIndex        |+|
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
- (void)horizontalScroller:(HorizontalScroller *)scroller doubleClickedViewAtIndex:(int)index
{
    [self horizontalScroller:scroller clickedViewAtIndex:index];
    
	FlickrImageViewController *ctrl = [[FlickrImageViewController alloc] initWithFlickrImage:[_imageSource imageAtIndex:index]];

    [self.navigationController pushViewController:ctrl animated:NO];
}


// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: numberOfViewsForHorizontalScroller                  |+|
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
- (NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller *)scroller
{
    return (_imageSource.count > 0) ? _imageSource.count : MAX_IMAGES;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  horizontalScroller: viewAtIndex                    |+|
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
static NSUInteger PICTURE_VIEW_WIDTH = 230;
static NSUInteger PICTURE_VIEW_HEIGHT = 230;
- (UIView *)horizontalScroller:(HorizontalScroller *)scroller viewAtIndex:(int)index
{
    FlickrImage *flickrImage = [_imageSource imageAtIndex:index];

    return [[PictureView alloc] initWithFrame:CGRectMake(0, 0, PICTURE_VIEW_WIDTH, PICTURE_VIEW_HEIGHT) picturePreview:(nil == flickrImage) ? @"" : flickrImage.previewURL];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  viewIndexForHorizontalScroller                     |+|
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
- (NSInteger)viewIndexForHorizontalScroller:(HorizontalScroller *)scroller
{
//    if(_currentPictureIndex < 1)
//    {
//        return _currentPictureIndex;
//    }
    
    return _currentPictureIndex - 1;
}

@end
