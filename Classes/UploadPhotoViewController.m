//
//  UploadPhotoViewController.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "UploadPhotoViewController.h"
#import "ThumbnailsViewController.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "UIAlertView+ActivityIndicator.h"
#import "PartyWareAppDelegate.h"

@implementation UploadPhotoViewController

@synthesize imageView;
@synthesize commentField;

@synthesize imageNeedsRotation;

- (id)initWithDelegate:(ThumbnailsViewController *)del image:(UIImage *)img {
	if (self = [super initWithNibName:@"UploadPhotoViewController"
							   bundle:[NSBundle mainBundle]]) {
		delegate = del;
		image = [img retain];
		imageNeedsRotation = NO;
		retryAlert = [[UIAlertView alloc] initWithTitle:@"Error uploading image"
												message:@"Would you like to try again?"
											   delegate:self cancelButtonTitle:@"Cancel"
									  otherButtonTitles:@"OK", nil];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
	[image release];
	[retryAlert release];
}

- (void)viewWillAppear:(BOOL)animated {
	imageView.image = image;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	originalCommentFrame = commentField.frame;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.imageView = nil;
	self.commentField = nil;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView != retryAlert)
		return;
	
	if (buttonIndex == retryAlert.cancelButtonIndex) {
		[delegate uploadControllerDidCancel];
	} else {
		[self uploadPhoto];
	}
}

- (void)doUpload {
	if (image.imageOrientation != UIImageOrientationUp) {
		UIGraphicsBeginImageContext(image.size);
		[image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
		[image release];
		image = [UIGraphicsGetImageFromCurrentImageContext() retain];
		UIGraphicsEndImageContext();
	}
	
	NSData *imageData = UIImageJPEGRepresentation(image, JPEG_COMPRESSION_QUALITY);
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:IMGUR_URL]];
	[request setPostValue:IMGUR_KEY forKey:@"key"];
	[request setData:imageData forKey:@"image"];
	[request startSynchronous];
	
	if ([request error]) {
		NSLog(@"ASIHTTPRequest error: %@", [request error]);
		[retryAlert show];
	} else {
		NSDictionary *response = [(NSDictionary *)[[request responseString] JSONValue] objectForKey:@"rsp"];
		if ([(NSString *)[response objectForKey:@"stat"] isEqualToString:@"ok"]) {
			NSDictionary *imageInfo = [response objectForKey:@"image"];
			NSString *urlString = [imageInfo objectForKey:@"original_image"];
			NSString *thumbURL = [imageInfo objectForKey:@"small_thumbnail"];
			[delegate uploadControllerDidUploadImage:image
											 withURL:urlString
											thumbURL:thumbURL
											 caption:commentField.text];
		} else {
			NSLog(@"imgur error: %@", [request responseString]);
			[retryAlert show];
		}
	}
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	if (alertView != retryAlert) {
		[self doUpload];
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
}

- (IBAction)uploadPhoto {
	[UIAlertView showActivityAlertViewWithTitle:@"Uploading photo" message:@"Please wait..."
									   delegate:self];
}

- (IBAction)cancel {
	[delegate uploadControllerDidCancel];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)keyboardWillShow:(NSNotification *)note {
	NSDictionary *userInfo = [note userInfo];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
	[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	
	CGRect newFrame = originalCommentFrame;
	newFrame.origin.y = self.view.frame.size.height -
	([[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height +
	 originalCommentFrame.size.height);
	newFrame.origin.x = 0;
	newFrame.size.width = self.view.frame.size.width;
	commentField.frame = newFrame;
	
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note {
	NSDictionary *userInfo = [note userInfo];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
	[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	
	commentField.frame = originalCommentFrame;
	
	[UIView commitAnimations];
}

@end
