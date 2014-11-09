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
#import "ImageInfoHTTPClient.h"

#import "AppDelegate.h"
#import "ImageDataInfo.h"
#import "ManagedObjectStore.h"


@interface UIButton(SystemBarButton)

+ (instancetype) buttonWithSystemStyle:(NSString *)title;

@end

@implementation UIButton(SystemBarButton)

+ (instancetype) buttonWithSystemStyle:(NSString *)title;
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    button.frame = CGRectMake(0, 0, 60, 40);
    
    return button;
}

@end

@interface FlickrImageListViewController()
{
    UITableView *_dataTable;
    
    FlickerImageSource *_imageSource;
    
    NSDictionary *_currentPictureData;
    int _currentPictureIndex;
    
    HorizontalScroller *_scroller;
    
    UIToolbar *_toolbar;
    
    ImageInfoHTTPClient *_imageInfoClient;
    
    LibraryAPI *_libraryAPI; //handles the notifs of a picture being dowloaded
    
    UIButton *_archiveButton;
    UIButton *_saveDeleteButton;
    UIBarButtonItem *_saveBarButton;
    UIBarButtonItem *_archiveBarButton;
    
    BOOL _isOnline;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation FlickrImageListViewController

@synthesize managedObjectContext;

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
        
        _imageInfoClient = [ImageInfoHTTPClient sharedInstance];
        
        _isOnline = YES;
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
static const NSUInteger DATATABLE_X_OFFSET = 100;
static const float ROW_HEIGHT = 60.0f;
- (void)createDataTable
{
    //create the data table that's gonna hold the picture's details
    _dataTable = [[UITableView alloc] initWithFrame:CGRectMake(DATATABLE_XPOS, DATATABLE_YPOS, self.view.frame.size.width - 2*DATATABLE_X_OFFSET, DATATABLE_HEIGHT) style:UITableViewStyleGrouped];
    _dataTable.delegate = self;
    _dataTable.dataSource = self;
    _dataTable.backgroundColor = [UIColor clearColor];
    _dataTable.opaque = NO;
    _dataTable.backgroundView = nil;
    _dataTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_dataTable];
    
    _dataTable.rowHeight = ROW_HEIGHT;
    [_dataTable registerClass:[FlickrImageCell class] forCellReuseIdentifier:NSStringFromClass([FlickrImageCell class])];
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

    _archiveButton = [UIButton buttonWithSystemStyle:@"Archive"];
    [_archiveButton addTarget:self action:@selector(didClickArchiveOnlineButton:) forControlEvents:UIControlEventTouchUpInside];
    _archiveBarButton = [[UIBarButtonItem alloc] initWithCustomView:_archiveButton];

    _saveDeleteButton = [UIButton buttonWithSystemStyle:@"Save"];
    [_saveDeleteButton addTarget:self action:@selector(didClickSaveDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    _saveBarButton = [[UIBarButtonItem alloc] initWithCustomView:_saveDeleteButton];
    _saveBarButton.enabled = NO;
    
    [_toolbar setItems:@[_archiveBarButton, space, space, space, space, rew, space, play, space, fwd, space, space, space, space, _saveBarButton]];
    
    [self.view addSubview:_toolbar];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  didClickSaveDeleteButton                           |+|
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
typedef enum
{
    TITLE_INDEX = 0,
    USERNAME_INDEX,
    REALNAME_INDEX,
    LOCATION_INDEX,
    DESCRIPTION_INDEX,
    POSTED_INDEX,
    TAKEN_INDEX
}FlickerImageValues_t;

-(void)didClickSaveDeleteButton:(UIButton *)button {
    
    NSArray *archive = [[ManagedObjectStore sharedInstance] allItemsOfType:@"ImageDataInfo"];
    
    NSString *title = _saveDeleteButton.titleLabel.text;
    if(YES == [title isEqualToString:@"Save"]) {
        
        //save using core data
        if(nil == _currentPictureData) {
            NSLog(@"Error : nil == _currentPictureData");
            
            return ;
        }
        
        FlickrImage *flickrImage = [_imageSource imageAtIndex:_currentPictureIndex];
        
        //check wether the image has been saved already
        NSArray *found = [archive filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pid == %@", flickrImage.pid]];
        if([found count] == 0) {
            
            ImageDataInfo *imageData = (ImageDataInfo *)[[ManagedObjectStore sharedInstance] managedObjectOfType:@"ImageDataInfo"];
            
            imageData.pid = flickrImage.pid;
            imageData.url = flickrImage.url;
            imageData.previewURL = flickrImage.previewURL;
            
            imageData.title = _currentPictureData[@"values"][TITLE_INDEX];
            imageData.username = _currentPictureData[@"values"][USERNAME_INDEX];
            imageData.realname = _currentPictureData[@"values"][REALNAME_INDEX];
            imageData.location = _currentPictureData[@"values"][LOCATION_INDEX];
            imageData.descr = _currentPictureData[@"values"][DESCRIPTION_INDEX];
            imageData.posted = _currentPictureData[@"values"][POSTED_INDEX];
            imageData.taken = _currentPictureData[@"values"][TAKEN_INDEX];
            
            [[ManagedObjectStore sharedInstance] writeToDisk];
            
            __block NSString *previewURL = imageData.previewURL;
            __block NSString *URL = imageData.url;
            __block NSString *pid = imageData.pid;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                //save the picture
                [LibraryAPI saveImageURL:URL toFile:pid];
                
                //save the preview pic
                [LibraryAPI saveImageURL:previewURL toFile:[NSString stringWithFormat:@"%@_preview", pid]];
            });
        }
    }
    else {

        FlickrImage *imagDataInfo = [_imageSource imageAtIndex:_currentPictureIndex];
        if(nil == imagDataInfo || nil == imagDataInfo.pid || [imagDataInfo.pid length] == 0) {
            NSLog(@"ERROR: Invalid picture data !!!");
            
            [[ManagedObjectStore sharedInstance] removeItem:NSStringFromClass([ImageDataInfo class]) predicate:[NSPredicate predicateWithFormat:@"pid == nil OR pid == ''"]];
        }
        else {
            [[ManagedObjectStore sharedInstance] removeItem:NSStringFromClass([ImageDataInfo class]) predicate:[NSPredicate predicateWithFormat:@"pid == %@", imagDataInfo.pid]];
            
            //remove the stored image files
//            [LibraryAPI deleteImageFile:imagDataInfo.pid];
//            [LibraryAPI deleteImageFile:[NSString stringWithFormat:@"%@_preview", imagDataInfo.pid]];
        }
        
        [self updatePhotos:_currentPictureIndex - 1];
    }
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  didClickArchiveButton                              |+|
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
-(void)didClickArchiveOnlineButton:(UIButton *)button
{
    NSString *deleteSaveTitle = @"Save";
    NSString *title = button.titleLabel.text;
    
    _currentPictureIndex = 0;
    
    if(YES == [title isEqualToString:@"Archive"]) {
        title = @"Online";
        deleteSaveTitle = @"Delete";
        _isOnline = NO;
    }
    else {
        title = @"Archive";
        deleteSaveTitle = @"Save";
        _isOnline = YES;
    }
    
    [_archiveButton setTitle:title forState:UIControlStateNormal];
    [_saveDeleteButton setTitle:deleteSaveTitle forState:UIControlStateNormal];
    
    [self updatePhotos];
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
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = delegate.managedObjectContext;
    
    _currentPictureIndex = 0;
    
    //create the uitable that will display the image info
    [self createDataTable];
    
    [self createToolbar];
    
    _imageSource = [FlickerImageSource new];
    _imageSource.delegate = self;
    
    [self updatePhotos];
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
//    [_scroller reload]; //refresh the scroller when returning to the main view
}

static UIActivityIndicatorView *rightBarButtonActivityIndicator = nil;

// |+|========================================================================|+|
// |+|                                                                        |+|
// |+|    FUNCTION NAME:  updatePhotos                                        |+|
// |+|                                                                        |+|
// |+|                                                                        |+|
// |+|    DESCRIPTION:   triggers an update of the current displayed pics     |+|
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
- (void)updatePhotos:(int)index;
{
    rightBarButtonActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, ACTIVITY_INDICATOR_WIDTH, ACTIVITY_INDICATOR_HEIGHT)];
    [rightBarButtonActivityIndicator sizeToFit];
    [rightBarButtonActivityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonActivityIndicator];

    [rightBarButtonActivityIndicator startAnimating];

    _currentPictureIndex = index;
    
    if(YES == _isOnline) {
        [_imageSource fetchRecentImages];
    }
    else {
        [_imageSource fetchArchivedImages];
    }
}

- (void)updatePhotos; {
    [self updatePhotos:0];
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
    
//    [_dataTable reloadData];
    
    //check for an out of range index
    if(pictureIndex >= _imageSource.count)
    {
        return ;
    }
    
    if(YES == _isOnline) {
        
        FlickrImage *flickrImage = [_imageSource imageAtIndex:pictureIndex];
        
        //start the download of image infos <----> this might take awhile
        [_imageInfoClient updateInfoForImage:flickrImage.pid
                                     success:^(NSDictionary *data){
                                         if(NO == [data isKindOfClass:[NSDictionary class]]) {
                                             NSLog(@"ERROR: wrong data type received !");
                                             
                                             FlickrImage *image = [FlickrImage image];
                                             _currentPictureData = [image tr_tableRepresentation];
                                             
                                             _saveBarButton.enabled = NO;
                                             
                                         } else {
                                             
                                             NSDictionary *owner = data[@"photo"][@"owner"];
                                             NSDictionary *description = data[@"photo"][@"description"];
                                             NSDictionary *dates = data[@"photo"][@"dates"];
                                             
                                             FlickrImage *flickrImage = [_imageSource imageAtIndex:_currentPictureIndex];
                                             //this will be the image to hold the complete data
                                             FlickrImage *complete = [FlickrImage imageWithImage:flickrImage];
                                             
                                             complete.username = owner[@"username"] ? owner[@"username"] : @"";
                                             complete.realname = owner[@"realname"] ? owner[@"realname"] : @"";
                                             complete.location = owner[@"location"] ? owner[@"location"] : @"";
                                             complete.description = description[@"_content"] ? description[@"_content"] : @"";
                                             complete.posted = dates[@"posted"] ? dates[@"posted"] : @"";
                                             complete.taken = dates[@"taken"] ? dates[@"taken"] : @"";
                                             
                                             _currentPictureData = [complete tr_tableRepresentation];
                                             
                                             _saveBarButton.enabled = YES;
                                         }
                                         
                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                             [_dataTable reloadData];
                                         });
                                     }
                                     failure:^(NSError *error) {
                                         NSLog(@"Error occured: %@", error);
                                         
                                         FlickrImage *image = [FlickrImage image];
                                         _currentPictureData = [image tr_tableRepresentation];
                                         
                                         _saveBarButton.enabled = NO;
                                         
                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                             [_dataTable reloadData];
                                         });
                                     }
         ];
    }
    else
    {
        FlickrImage *flickrImage = [_imageSource imageAtIndex:pictureIndex];
        
        _currentPictureData = [flickrImage tr_tableRepresentation];
        
        _saveBarButton.enabled = YES;
        
        [_dataTable reloadData];
    }
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
}

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
static NSString * const PDTITLES = @"titles";
static NSString * const PDVALUES = @"values";
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FlickrImageCell *cell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([FlickrImageCell class])];
    
    // cell selection style none
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setTextColor:[UIColor whiteColor]];
    
    if(nil == _currentPictureData)
    {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.frame = CGRectMake(0, 0, ACTIVITY_INDICATOR_WIDTH, ACTIVITY_INDICATOR_HEIGHT);
        
        cell.accessoryView = spinner;

        [spinner startAnimating];
        
        //create a bogus empty image so we get the title for each row
        FlickrImage *emptyImage = [FlickrImage image];
        
        cell.title = [emptyImage tr_tableRepresentation][PDTITLES][indexPath.row];
        cell.content = @"";
    }
    else
    {
        cell.title = _currentPictureData[PDTITLES][indexPath.row];
        cell.content = _currentPictureData[PDVALUES][indexPath.row];
        
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
    _saveBarButton.enabled = NO;
    
    _currentPictureIndex = index;
    
    [self showDataForPictureAtIndex:index];
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
    return _currentPictureIndex - 1;
}

#pragma mark - FlickerImageSourceDelegate

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:  didCompleteDownloadingImage                        |+|
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
- (void)didCompleteDownloadingImages
{
    @try {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updatePhotos)];
        
        //create and add the scroller to the scene
        _scroller = [[HorizontalScroller alloc] initWithFrame:CGRectMake(0, SCROLLER_Y_POS, self.view.frame.size.width, SCROLLER_HEIGHT)];
        _scroller.backgroundColor = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
        _scroller.delegate = self;
        [self.view addSubview:_scroller];
        
        [self reloadScroller];
    }
    @catch(NSException *e) {
        NSLog(@"Exception caught: %@", e);
    }
    
    [rightBarButtonActivityIndicator stopAnimating];
}


@end
