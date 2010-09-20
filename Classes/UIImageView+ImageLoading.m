//
//  UIImageView+ImageLoading.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/18/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "UIImageView+ImageLoading.h"
#import "ASIHTTPRequest.h"

@implementation UIImageView (ImageLoading)

- (void)loadImageWithURL:(NSURL *)url {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	NSError *error = [request error];
	if (error) {
		NSLog(@"Error loading image: %@", error);
	} else {
		UIImage *image = [UIImage imageWithData:[request responseData]];
		self.image = image;
	}
	
	[pool release];
}

- (void)loadImageWithURL:(NSURL *)url synchronous:(BOOL)isSynchronous {
	if (isSynchronous)
		[self loadImageWithURL:url];
	else 
		[self performSelectorInBackground:@selector(loadImageWithURL:)
							   withObject:url];
}

@end
