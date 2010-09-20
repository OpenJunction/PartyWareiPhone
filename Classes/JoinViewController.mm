//
//  RootViewController.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/9/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JoinViewController.h"
#import "QRCodeReader.h"
#import "PartyWareAppDelegate.h"
#import "PartyWareProp.h"
#import "JXJunctionActor.h"
#import "JXProp.h"
#import "JXXMPPSwitchboardConfig.h"
#import "JXJunctionMaker.h"
#import "UIAlertView+ActivityIndicator.h"

@interface JunctionActor : JXJunctionActor {
	JXProp *prop;
}
- (id)initWithProp:(JXProp *)p;
@end

@implementation JunctionActor
- (id)initWithProp:(JXProp *)p {
	if (self = [super initWithRole:@"participant"]) {
		prop = [p retain];
	}
	return self;
}
- (void)dealloc {
	[prop release];
	[super dealloc];
}
- (void)onActivityJoin {
	NSLog(@"Joined!");
}
- (void)onMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)header {
	NSLog(@"Got msg!");
}
- (BOOL)onDisconnect {
	NSLog(@"Disconnected!");
	return NO;
}
- (NSArray *)getInitialExtras {
	return [NSArray arrayWithObject:prop];
}
@end

@implementation JoinViewController

- (void)awakeFromNib {
	retryAlert = [[UIAlertView alloc] initWithTitle:@"Connection error"
											message:@"Could not join the party"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
	lastPartyName = nil;
}

- (void)dealloc {
	[retryAlert release];
	[actor release];
	[prop release];
	[lastPartyURL release];
	[lastPartyName release];
	[invitationURL release];
    [super dealloc];
}

@synthesize statusLabel;
@synthesize rejoinButton;

@synthesize lastPartyURL;
@synthesize lastPartyName;
@synthesize invitationURL;

- (void)propChanged {
	[statusLabel performSelectorOnMainThread:@selector(setText:)
								  withObject:[NSString stringWithFormat:@"In Party: %@", [prop partyName]]
							   waitUntilDone:NO];
}

- (void)initPropWithJunctionURL:(NSURL *)url {
	[prop release];
	prop = [[PartyWareProp alloc] initWithName:@"party_prop"];
	[prop addChangeListener:APP_DELEGATE];
	[prop addChangeListener:APP_DELEGATE.propChangeListener];
	
	[actor leave];
	[actor release];
	actor = [[JunctionActor alloc] initWithProp:prop];
	
	JXXMPPSwitchboardConfig *sb = [[JXXMPPSwitchboardConfig alloc] initWithHost:[url host]];
	[sb setConnectionTimeout:10];
	if ([[[JXJunctionMaker getInstanceWithSwitchboard:[sb autorelease]]
		 newJunctionWithURL:url actor:actor] autorelease]) {
		APP_DELEGATE.prop = prop;
		APP_DELEGATE.partyURL = url;
	} else {
		[retryAlert show];
	}
}

- (void)joinPartyWithURL:(NSURL *)url {
	self.invitationURL = url;
	[UIAlertView showActivityAlertViewWithTitle:@"Joining party"
										message:@"Please wait..."
									   delegate:self];
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	if (alertView != retryAlert) {
		[self initPropWithJunctionURL:invitationURL];
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
}

- (void)viewDidLoad {
	if (lastPartyName) {
		[rejoinButton setTitle:[NSString stringWithFormat:@"Rejoin \"%@\"", lastPartyName]
					  forState:UIControlStateNormal];
	} else {
		[rejoinButton removeFromSuperview];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.statusLabel = nil;
	self.rejoinButton = nil;
}



- (IBAction)rejoinLastParty {
	[self joinPartyWithURL:lastPartyURL];
}

- (IBAction)scanPartyInvitation {
	ZXingWidgetController *zxController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
	QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
	zxController.readers = [NSSet setWithObjects:[qrcodeReader autorelease], nil];
	[self presentModalViewController:[zxController autorelease] animated:YES];
}

- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result {
	[self dismissModalViewControllerAnimated:NO];
	[self joinPartyWithURL:[NSURL URLWithString:result]];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

@end
