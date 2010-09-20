//
//  UIImageView+ImageLoading.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/18/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImageView (ImageLoading)

- (void)loadImageWithURL:(NSURL *)url synchronous:(BOOL)isSynchronous;

@end
