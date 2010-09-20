//
//  PeopleViewController.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/26/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PartyWareProp;

@interface PeopleViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource> {
	UITableView *userTableView;
	
	NSMutableDictionary *userThumbnails;
	
	PartyWareProp *prop;
}

@property (nonatomic, retain) IBOutlet UITableView *userTableView;

@property (readonly) NSMutableDictionary *userThumbnails;
@property (retain) PartyWareProp *prop;

- (void)propChanged;

- (void)profileEditorDidCancel;
- (void)profileEditorDidSaveWithName:(NSString *)name
							   email:(NSString *)email
							imageURL:(NSString *)imageURL;

- (IBAction)editProfile;

@end
