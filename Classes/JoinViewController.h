//
//  RootViewController.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/9/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingWidgetController.h"

@class JXJunctionActor;
@class PartyWareProp;

@interface JoinViewController : UIViewController <ZXingDelegate, UIAlertViewDelegate> {
	UILabel *statusLabel;
	UIButton *rejoinButton;
	UIAlertView *retryAlert;
	
	JXJunctionActor *actor;
	PartyWareProp *prop;
	
	NSURL *lastPartyURL;
	NSString *lastPartyName;
	
	NSURL *invitationURL;
}

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIButton *rejoinButton;

@property (nonatomic, retain) NSURL *lastPartyURL;
@property (nonatomic, retain) NSString *lastPartyName;
@property (nonatomic, retain) NSURL *invitationURL;

- (IBAction)scanPartyInvitation;
- (IBAction)rejoinLastParty;

- (void)propChanged;

@end
