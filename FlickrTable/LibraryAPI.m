//
//  LibraryAPI.m
//  FlickrTable
//
//  Created by Stefan Buretea on 10/17/13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "LibraryAPI.h"
#import "FlickrConstants.h"
#import "FlickerImageSource.h"
#import "UIImageView+AFNetworking.h"

@interface FlickerImageCacheInfo : NSData

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) UIImage *image;

@end

@implementation FlickerImageCacheInfo

@synthesize url;
@synthesize image;

@end

@implementation LibraryAPI
{
    NSMutableData *_responseData;
    
    NSString *_pid; //picture id
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
+ (LibraryAPI *)sharedInstance
{
    static LibraryAPI *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
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
- (id) init
{
    self = [super init];
    if(self)
    {
        //register for notifications when a preview image needs to be downloaded
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:DOWNLOAD_IMAGE_NOTIFICATION object:nil];
    }
    
    return self;
}

NS_INLINE void forceImageDecompression(UIImage *image)
{
    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(imageRef),
                                                 CGImageGetHeight(imageRef),
                                                 8,
                                                 CGImageGetWidth(imageRef) * 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    
    if (!context) { NSLog(@"Could not create context for image decompression"); return; }
    CGContextDrawImage(context, (CGRect){{0.0f, 0.0f}, {CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)}}, imageRef);
    
    CFRelease(context);
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   downloadImage                                     |+|
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
- (void) downloadImage:(NSNotification *)notification
{
    @autoreleasepool {
        
        __block UIImageView *imageView = notification.userInfo[@"previewImageView"];
        NSString *previewImageURL = notification.userInfo[@"previewURL"];

        [imageView setImageWithURL:[NSURL URLWithString:previewImageURL]];
    
        return;
    
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *itemPath = [NSString stringWithFormat:@"%@/%@.jpg", docDir, previewImageURL];
        if(NO == [fm fileExistsAtPath:itemPath]) {
            
            NSMutableURLRequest *URLRequest = [NSMutableURLRequest URLRequestWithString:previewImageURL];
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:URLRequest
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 if(data) {
                                                     __block UIImage *image = [UIImage imageWithData:data];
                                                     
                                                     forceImageDecompression(image);
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [imageView setImage:image];
                                                     });
                                                 }
            }] resume];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
            });
        }
    }
}

#define IS_VALID_STRING(string) (nil != string && [string length] > 0)

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:    deleteImageFile                                  |+|
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
+ (BOOL)deleteImageFile:(NSString *)filename
{
    if(NO == IS_VALID_STRING(filename))
    {
        NSLog(@"ERROR : Invalid filename !!!");
        
        return NO;
    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *itemPath = [NSString stringWithFormat:@"%@/%@.jpg", docDir, filename];
    if(NO == [fm fileExistsAtPath:itemPath])
    {
        NSLog(@"ERROR : Filename %@ doesnt exist !!!", filename);
        
        return NO;
    }
    
    NSError *error;
    [fm removeItemAtPath:itemPath error:&error];
    if(nil != error)
    {
        NSLog(@"Error occured %@", [error localizedDescription]);
        
        return NO;
    }
    
    return YES;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:    saveImageURL                                     |+|
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
+ (BOOL)saveImageURL:(NSString *)URL toFile:(NSString *)filename
{
    if(NO == IS_VALID_STRING(URL)) {
        
        NSLog(@"ERROR : Invalid URL !!!");
        
        return NO;
    }

    if(NO == IS_VALID_STRING(filename)) {
        
        NSLog(@"ERROR : Invalid filename !!!");
        
        return NO;
    }
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URL]]];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // If you go to the folder below, you will find those pictures
    NSLog(@"%@",docDir);
    
    NSLog(@"saving png");
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.jpg", docDir, filename];
    NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    [data writeToFile:pngFilePath atomically:YES];
    
    return YES;
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
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
