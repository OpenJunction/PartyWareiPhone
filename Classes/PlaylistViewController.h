//
//  PlaylistViewController.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/11/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDataServiceGoogleYouTube;
@class PartyWareProp;

@interface PlaylistViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
	NSMutableDictionary *playlistThumbnails;
	
	NSArray *searchResultVideos;
	NSMutableArray *searchResultThumbnails;
	
	GDataServiceGoogleYouTube *youTubeService;
	
	PartyWareProp *prop;
	
	UITableViewCell *playlistTableCell;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *playlistTableCell;

@property (retain) NSArray *searchResultVideos;
@property (retain) NSMutableArray *searchResultThumbnails;
@property (retain) NSMutableDictionary *playlistThumbnails;

@property (nonatomic, retain) PartyWareProp *prop;

- (void)propChanged;

- (IBAction)voteForVideo:(id)sender;

@end
