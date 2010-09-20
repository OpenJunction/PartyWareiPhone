//
//  ThumbnailView.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/17/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ThumbnailView.h"
#import "ThumbnailsViewController.h"
#import "ASIHTTPRequest.h"
#import "UIImageView+ImageLoading.h"

@implementation ThumbnailView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor grayColor];
		self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)loadThumbnailFromInfo:(NSDictionary *)info {
	NSURL *url = [NSURL URLWithString:[info objectForKey:@"thumbUrl"]];
	[self loadImageWithURL:url synchronous:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate thumbnailSelected:self];
}

- (void)dealloc {
    [super dealloc];
}


@end
