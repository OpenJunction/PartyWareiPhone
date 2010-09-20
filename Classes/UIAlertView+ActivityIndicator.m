//
//  UIAlertView+ActivityIndicator.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/27/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "UIAlertView+ActivityIndicator.h"


@implementation UIAlertView (ActivityIndicator)

+ (UIAlertView *)showActivityAlertViewWithTitle:(NSString *)title
										message:(NSString *)message
									   delegate:(id<UIAlertViewDelegate>)delegate {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:nil
										  otherButtonTitles:nil];
	[alert show];
	
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicator.center = CGPointMake(alert.bounds.size.width / 2,
										   alert.bounds.size.height - 40);
	[activityIndicator startAnimating];
	[alert addSubview:[activityIndicator autorelease]];
	
	return [alert autorelease];
}

@end
