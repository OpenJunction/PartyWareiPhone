//
//  PhotoViewController.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/17/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoViewController : UIViewController {
	UIImageView *imageView;
	UILabel *captionLabel;
	UIActivityIndicatorView *activityIndicator;
	UIBarButtonItem *previousButton;
	UIBarButtonItem *nextButton;
	UIToolbar *toolbar;
	
	NSDate *lastTouch;
	NSTimer *hideBarsTimer;
	
	NSArray *images;
	int imageIndex;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *captionLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *previousButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *nextButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (retain) NSDate *lastTouch;

@property (retain) NSArray *images;

- (void)showImageWithIndex:(int)index;

- (IBAction)changeImage:(id)sender;

@end
