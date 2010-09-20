//
//  ThumbnailView.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/17/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbnailsViewController;

@interface ThumbnailView : UIImageView {
	ThumbnailsViewController *delegate;
}

@property (nonatomic, assign) ThumbnailsViewController *delegate;

- (void)loadThumbnailFromInfo:(NSDictionary *)info;

@end
