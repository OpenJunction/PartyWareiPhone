//
//  PlaylistViewController.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/11/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "PlaylistViewController.h"
#import "PartyWareProp.h"
#import "GDataYouTube.h"
#import "PartyWareAppDelegate.h"
#import "UIImageView+ImageLoading.h"

static NSString	* const YOUTUBE_URL_FORMAT = @"http://www.youtube.com/watch?v=%@";

enum {
	CELL_IMG_TAG = 1,
	CELL_LABEL_TAG,
	CELL_UPVOTE_TAG,
	CELL_DOWNVOTE_TAG
};

@implementation PlaylistViewController

@synthesize playlistTableCell;

@synthesize searchResultVideos;
@synthesize searchResultThumbnails;
@synthesize playlistThumbnails;
@synthesize prop;

- (void)reloadTable {
	int numSectionsOld = [self.tableView numberOfSections];
	int numSectionsNew = [self numberOfSectionsInTableView:self.tableView];
	if (numSectionsOld == numSectionsNew)
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numSectionsNew)]
					  withRowAnimation:UITableViewRowAnimationNone];
	else 
		[self.tableView reloadData];
}

- (void)propChanged {
	if ([self isViewLoaded])
		[self performSelectorOnMainThread:@selector(reloadTable)
							   withObject:nil waitUntilDone:NO];
}

- (IBAction)voteForVideo:(id)sender {
	UIButton *button = (UIButton *)sender;
	BOOL isUpvote = (button.tag == CELL_UPVOTE_TAG);
	int index = [[button superview] superview].tag;
	
	NSDictionary *videoInfo = [[prop objectsWithType:@"youtube"] objectAtIndex:index];
	NSString *itemID = [videoInfo objectForKey:@"id"];
	if (isUpvote)
		[prop upvoteVideoWithItemID:itemID];
	else
		[prop downvoteVideoWithItemID:itemID];
	
	NSLog(@"%@ video %d", isUpvote? @"Upvote":@"Downvote", index);
}

#pragma mark -
#pragma mark View lifecycle

- (void)awakeFromNib {
	playlistThumbnails = [[NSMutableDictionary alloc] init];
	youTubeService = [[GDataServiceGoogleYouTube alloc] init];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		return 1;
	} else {
		int numVideos = [[prop objectsWithType:@"youtube"] count];
		return (numVideos > 0)? 2 : 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return nil;
	} else {
		if (section == 0) {
			return @"Now Playing";
		} else {
			return @"Playlist";
		}
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		return [searchResultVideos count];
	} else {
		int numVideos = [[prop objectsWithType:@"youtube"] count];
		if (section == 0) {
			return (numVideos > 0)? 1 : 0;
		} else {
			return numVideos;
		}
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	// Configure the cell...
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
		}
		
		GDataEntryYouTubeVideo *video = [searchResultVideos objectAtIndex:indexPath.row];
		UIImage *thumbnail = [searchResultThumbnails objectAtIndex:indexPath.row];
		
		cell.textLabel.text = [[video title] stringValue];
		if (thumbnail != (UIImage *)[NSNull null])
			cell.imageView.image = thumbnail;
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistTableCell"];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"PlaylistTableCell" owner:self options:nil];
			cell = playlistTableCell;
			self.playlistTableCell = nil;
		}
		
		cell.tag = indexPath.row;
		NSDictionary *videoInfo = [[prop objectsWithType:@"youtube"] objectAtIndex:indexPath.row];
		
		UILabel *label = (UILabel *)[cell.contentView viewWithTag:CELL_LABEL_TAG];
		UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:CELL_IMG_TAG];
		
		label.text = [videoInfo objectForKey:@"caption"];
		NSString *thumbURL = [videoInfo objectForKey:@"thumbUrl"];
		imageView.image = [self.playlistThumbnails objectForKey:thumbURL];
		if (imageView.image == nil) {
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:thumbURL]];
			GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
			[fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
				if (error) {
					NSLog(@"fetcher error: %@", error);
				} else {
					[self.playlistThumbnails setObject:[UIImage imageWithData:data]
												forKey:thumbURL];
					[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
										  withRowAnimation:UITableViewRowAnimationNone];
				}
			}];
		}
	}
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		GDataEntryYouTubeVideo *video = [searchResultVideos objectAtIndex:indexPath.row];
		NSString *thumbUrl = [[[video mediaGroup] highQualityThumbnail] URLString];
		
		UIImage *thumbnail = [searchResultThumbnails objectAtIndex:indexPath.row];
		if (thumbnail) {
			[self.playlistThumbnails setObject:thumbnail forKey:thumbUrl];
		}
		
		NSString *videoID = [[video mediaGroup] videoID];
		[prop addYouTubeVideoWithUserID:APP_DELEGATE.userID
								videoID:videoID
									url:[NSString stringWithFormat:YOUTUBE_URL_FORMAT, videoID]
							   thumbURL:thumbUrl
								caption:[[video title] stringValue]
								   time:(long)time(0)];
		
		[self.searchDisplayController setActive:NO animated:YES];
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		NSDictionary *videoInfo = [[prop objectsWithType:@"youtube"] objectAtIndex:indexPath.row];
		NSURL *videoUrl = [NSURL URLWithString:[videoInfo objectForKey:@"url"]];
		[[UIApplication sharedApplication] openURL:videoUrl];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[playlistThumbnails release];
	[searchResultVideos release];
	[searchResultThumbnails release];
	[youTubeService release];
	[prop release];
	[super dealloc];
}

#pragma mark -
#pragma mark Search display delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	return NO;
}

#pragma mark -
#pragma mark Search bar delegate

- (void)showSearchActivityIndicator {
	UIView *loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[loadingView addSubview:activityIndicator];
	activityIndicator.center = CGPointMake(loadingView.center.x, 175);
	
	self.searchDisplayController.searchResultsTableView.tableHeaderView = [loadingView autorelease];
	[activityIndicator startAnimating];
	[activityIndicator release];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	UITableView *searchResultsTableView = self.searchDisplayController.searchResultsTableView;
	if (searchResultsTableView.tableHeaderView == nil) {
		UIView *blankView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
		searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
		searchResultsTableView.tableHeaderView = [blankView autorelease];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	if ([[searchBar text] length] == 0) {
		return;
	}
	
	[self showSearchActivityIndicator];
	
	NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:kGDataYouTubeFeedIDFull];
	
	GDataQueryYouTube *query = [GDataQueryYouTube queryWithFeedURL:feedURL];
	[query setVideoQuery:[searchBar text]];
	[query setFormat:@"5"]; // only embeddable videos
	
	[youTubeService fetchFeedWithQuery:query
							  delegate:self
					 didFinishSelector:@selector(ticket:finishedWithFeed:error:)];
}

#pragma mark -
#pragma mark GData

- (void)loadSearchResultThumbnails {
	self.searchResultThumbnails = [NSMutableArray arrayWithCapacity:[searchResultVideos count]];
	for (int i = 0; i < [searchResultVideos count]; i++) {
		[searchResultThumbnails addObject:[NSNull null]];
		
		GDataEntryYouTubeVideo *video = [searchResultVideos objectAtIndex:i];
		GDataMediaThumbnail *thumbnail = [[video mediaGroup] highQualityThumbnail];
		NSURL *imageURL = [NSURL URLWithString:[thumbnail URLString]];
		GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:[NSURLRequest requestWithURL:imageURL]];
		[fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
			if (error) {
				NSLog(@"fetcher error: %@", error);
			} else {
				[searchResultThumbnails replaceObjectAtIndex:i
												  withObject:[UIImage imageWithData:data]];
				[self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
																		   withRowAnimation:UITableViewRowAnimationNone];
			}
		}];
	}
}
		
- (void)ticket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedYouTubeVideo *)feed
		 error:(NSError *)error {
	if (error) {
		self.searchResultVideos = [NSArray array];
	} else {
		self.searchResultVideos = [feed entries];
		[self loadSearchResultThumbnails];
	}
	[self.searchDisplayController.searchResultsTableView reloadData];
	self.searchDisplayController.searchResultsTableView.tableHeaderView = nil;
	self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
}


@end

