//
//  PeopleViewController.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/26/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "PeopleViewController.h"
#import "PartyWareProp.h"
#import "GDataHTTPFetcher.h"
#import "EditProfileViewController.h"
#import "PartyWareAppDelegate.h"

@implementation PeopleViewController

@synthesize userTableView;

@synthesize userThumbnails;
@synthesize prop;

- (void)propChanged {
	if ([self isViewLoaded]) {
		[self.userTableView performSelectorOnMainThread:@selector(reloadData)
										 withObject:nil waitUntilDone:NO];
	}
}

- (void)profileEditorDidCancel {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)profileEditorDidSaveWithName:(NSString *)name
							   email:(NSString *)email
							imageURL:(NSString *)imageURL {
	[self dismissModalViewControllerAnimated:YES];
	[prop updateUserWithID:APP_DELEGATE.userID name:name email:email imageURL:imageURL];
}

- (IBAction)editProfile {
	EditProfileViewController *editor = [EditProfileViewController profileEditorWithDelegate:self];
	[self presentModalViewController:editor animated:YES];
}

#pragma mark -
#pragma mark View lifecycle

- (void)awakeFromNib {
	userThumbnails = [[NSMutableDictionary alloc] init];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[prop objectsWithType:@"user"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSDictionary *userInfo = [[prop objectsWithType:@"user"] objectAtIndex:indexPath.row];
	NSString *name = [userInfo objectForKey:@"name"];
	NSString *email = [userInfo objectForKey:@"email"];
	NSString *thumbURL = [userInfo objectForKey:@"imageUrl"];
	
	cell.textLabel.text = name;
	cell.detailTextLabel.text = email;
	cell.imageView.image = [self.userThumbnails objectForKey:thumbURL];
	
	if (cell.imageView.image == nil) {
		cell.imageView.image = [UIImage imageWithContentsOfFile:@"default_profile.jpg"];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:thumbURL]];
		GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
		[fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
			if (error) {
				NSLog(@"fetcher error: %@", error);
			} else {
				[self.userThumbnails setObject:[UIImage imageWithData:data]
										forKey:thumbURL];
				[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								 withRowAnimation:UITableViewRowAnimationNone];
			}
		}];
	}
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
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
	self.userTableView = nil;
}


- (void)dealloc {
	[userThumbnails release];
	[prop release];
    [super dealloc];
}


@end

