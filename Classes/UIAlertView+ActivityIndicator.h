//
//  UIAlertView+ActivityIndicator.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/27/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIAlertView (ActivityIndicator)

+ (UIAlertView *)showActivityAlertViewWithTitle:(NSString *)title
										message:(NSString *)message
									   delegate:(id<UIAlertViewDelegate>)delegate;

@end
