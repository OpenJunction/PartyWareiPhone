//
//  UploadPhotoViewController.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@class ThumbnailsViewController;

@interface UploadPhotoViewController : UIViewController
<UITextFieldDelegate, UIAlertViewDelegate> {
	UIImageView *imageView;
	UITextField *commentField;
	
	UIAlertView *retryAlert;
	
	CGRect originalCommentFrame;
	
	UIImage *image;
	BOOL imageNeedsRotation;
	
	ThumbnailsViewController *delegate;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextField *commentField;

@property (nonatomic) BOOL imageNeedsRotation;

- (id)initWithDelegate:(ThumbnailsViewController *)del image:(UIImage *)img;

- (IBAction)uploadPhoto;
- (IBAction)cancel;

@end
