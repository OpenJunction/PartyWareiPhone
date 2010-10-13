//
//  PartyWareAppDelegate.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/9/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import "PartyWareAppDelegate.h"
#import "JoinViewController.h"
#import "PeopleViewController.h"
#import "ThumbnailsViewController.h"
#import "PlaylistViewController.h"
#import "PartyWareProp.h"

NSString * const IMGUR_KEY = @"07e9070728fcfad67e43546c0e229cc6";
NSString * const IMGUR_URL = @"http://imgur.com/api/upload.json";
CGFloat const JPEG_COMPRESSION_QUALITY = 0.5;

@interface PropChangeListener : NSObject <JXIPropChangeListener> {}
@end

@implementation PropChangeListener
- (NSString *)type {
	return EVT_CHANGE;
}
- (void)onChange:(id)data {
	[APP_DELEGATE onChange:data];
}
@end

@implementation PartyWareAppDelegate

@synthesize window;
@synthesize tabBarController;

@synthesize prop;
@synthesize propChangeListener;

@synthesize partyURL;

- (NSString *)userID {
	return [UIDevice currentDevice].uniqueIdentifier;
}

- (NSString *)type {
	return EVT_SYNC;
}

- (void)onChange:(id)data {
	[joinViewController propChanged];
	[peopleViewController propChanged];
	[playlistViewController propChanged];
	[photosViewController propChanged];
}

- (void)setProp:(PartyWareProp *)p {
	[prop release];
	prop = [p retain];
	
	peopleViewController.prop = prop;
	playlistViewController.prop = prop;
	photosViewController.prop = prop;
	
	[[tabBarController.tabBar.items objectAtIndex:1] setEnabled:prop? YES : NO];
	[[tabBarController.tabBar.items objectAtIndex:2] setEnabled:prop? YES : NO];
	[[tabBarController.tabBar.items objectAtIndex:3] setEnabled:prop? YES : NO];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	propChangeListener = [[PropChangeListener alloc] init];
	
	NSArray *viewControllers = [tabBarController viewControllers];
	joinViewController = [viewControllers objectAtIndex:0];
	peopleViewController = (PeopleViewController *)[[viewControllers objectAtIndex:1] topViewController];
	playlistViewController = [viewControllers objectAtIndex:2];
	photosViewController = (ThumbnailsViewController *)[[viewControllers objectAtIndex:3] topViewController];
	
	NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *savePath = [[savePaths objectAtIndex:0] stringByAppendingString:@"/partyData"];
	NSString *partyData = [NSString stringWithContentsOfFile:savePath encoding:NSUTF8StringEncoding error:NULL];
	NSArray *partyComponents = [partyData componentsSeparatedByString:@" "];
	
	// TODO - Disabling this for demo - re-enable for realistic experience.
	//if (![[partyComponents objectAtIndex:0] isEqualToString:@"(null)"]) {
	//	joinViewController.lastPartyURL = [NSURL URLWithString:[partyComponents objectAtIndex:0]];
	//	joinViewController.lastPartyName = [partyComponents objectAtIndex:1];
	//}
	// Hard-coding this for demo.
	joinViewController.lastPartyURL = [NSURL URLWithString: @"junction://openjunction.org/partyware_session"];
	joinViewController.lastPartyName = @"Best Party Ever";
	
    // Override point for customization after application launch.
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	if (partyURL && [prop partyName]) {
		NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *savePath = [[savePaths objectAtIndex:0] stringByAppendingString:@"/partyData"];
		NSString *partyData = [NSString stringWithFormat:@"%@ %@", [partyURL absoluteString], [prop partyName]];
		[partyData writeToFile:savePath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
	}
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[prop release];
	[propChangeListener release];
	[partyURL release];
	[tabBarController release];
    [window release];
    [super dealloc];
}


@end
