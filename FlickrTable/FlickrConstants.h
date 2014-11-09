//
//  FlickrConstants.h
//  FlickrTable
//
//  Created by Stefan Buretea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

static NSString *const FLICKR_KEY = @"f06b4cc276e30ea4eea81066f5681273";
static NSString *const FLICKR_SECRET = @"ca39afe44ba1341f";

static NSString *const DOWNLOAD_IMAGE_NOTIFICATION = @"DownloadImageNotification";
static NSString *const IMAGE_INFO_NOTIFICATION = @"ImageInfoNotification";
static const NSUInteger MAX_IMAGES = 100;
static NSString *const FLICKR_URL_PHOTO_INFO = @"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1";
static NSString *const FLICKR_URL_REQUEST_RECENT = @"https://api.flickr.com/services/rest?method=flickr.photos.getRecent&api_key=%@&format=json&nojsoncallback=1";
