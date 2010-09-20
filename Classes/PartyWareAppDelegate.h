//
//  PartyWareAppDelegate.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/9/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXIPropChangeListener.h"

#define APP_DELEGATE ((PartyWareAppDelegate *)[UIApplication sharedApplication].delegate)

@class JoinViewController;
@class PeopleViewController;
@class PlaylistViewController;
@class ThumbnailsViewController;
@class PartyWareProp;

extern NSString * const IMGUR_KEY;
extern NSString * const IMGUR_URL;
extern CGFloat const JPEG_COMPRESSION_QUALITY;

@interface PartyWareAppDelegate : NSObject <UIApplicationDelegate, JXIPropChangeListener> {
    UIWindow *window;
	UITabBarController *tabBarController;
	
	JoinViewController *joinViewController;
	PeopleViewController *peopleViewController;
	PlaylistViewController *playlistViewController;
	ThumbnailsViewController *photosViewController;
	
	PartyWareProp *prop;
	id<JXIPropChangeListener> propChangeListener;
	
	NSURL *partyURL;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) PartyWareProp *prop;
@property (nonatomic, retain) id<JXIPropChangeListener> propChangeListener;

@property (nonatomic, retain) NSURL *partyURL;

@property (nonatomic, readonly) NSString *userID;

@end

