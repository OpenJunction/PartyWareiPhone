//
//  ProfileViewController.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/27/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "EditProfileViewController.h"
#import "PeopleViewController.h"
#import "UIAlertView+ActivityIndicator.h"
#import "ASIFormDataRequest.h"
#import "PartyWareAppDelegate.h"
#import "JSON.h"

@implementation EditProfileViewController

@synthesize imageView;
@synthesize nameField;
@synthesize emailField;

+ (EditProfileViewController *)profileEditorWithDelegate:(PeopleViewController *)del {
	EditProfileViewController *editor = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController"
																					bundle:[NSBundle mainBundle]];
	editor->delegate = del;
	return [editor autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.imageView = nil;
	self.nameField = nil;
	self.emailField = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self.view bringSubviewToFront:textField];
	currentField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)keyboardWillShow:(NSNotification *)note {
	returnFrame = currentField.frame;
	
	NSDictionary *userInfo = [note userInfo];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
	[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	
	CGRect newFrame = currentField.frame;
	newFrame.origin.y = self.view.frame.size.height -
	([[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height +
	 currentField.frame.size.height);
	newFrame.origin.x = 0;
	newFrame.size.width = self.view.frame.size.width;
	currentField.frame = newFrame;
	
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note {
	NSDictionary *userInfo = [note userInfo];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
	[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	
	currentField.frame = returnFrame;
	
	[UIView commitAnimations];
}

- (IBAction)changePicture {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Profile Picture"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Photo Library", @"Take Photo", @"Use Default", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	switch (buttonIndex) {
		case 0:
			imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentModalViewController:imagePicker animated:YES];
			break;
		case 1:
			imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentModalViewController:imagePicker animated:YES];
			break;
		case 2: {
			NSString *defaultPath = [[NSBundle mainBundle] pathForResource:@"default_profile" ofType:@"jpg"];
			imageView.image = [UIImage imageWithContentsOfFile:defaultPath];
			break;
		} default:
			break;
	}
	[imagePicker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissModalViewControllerAnimated:YES];
	imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
}

- (NSString *)uploadPicture {
	UIImage *image = imageView.image;
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
		return nil;
	} else {
		NSDictionary *response = [(NSDictionary *)[[request responseString] JSONValue] objectForKey:@"rsp"];
		if ([(NSString *)[response objectForKey:@"stat"] isEqualToString:@"ok"]) {
			NSDictionary *imageInfo = [response objectForKey:@"image"];
			return [imageInfo objectForKey:@"small_thumbnail"];
		} else {
			NSLog(@"imgur error: %@", [request responseString]);
			return nil;
		}
	}
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	NSString *imageURL = [self uploadPicture];
	[alertView dismissWithClickedButtonIndex:0 animated:YES];
	[delegate profileEditorDidSaveWithName:nameField.text
									 email:emailField.text
								  imageURL:imageURL];
}

- (IBAction)save {
	[UIAlertView showActivityAlertViewWithTitle:@"Saving profile"
										message:@"Please wait..."
									   delegate:self];
}

- (IBAction)cancel {
	[delegate profileEditorDidCancel];
}


@end
