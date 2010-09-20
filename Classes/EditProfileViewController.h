//
//  ProfileViewController.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/27/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PeopleViewController;

@interface EditProfileViewController : UIViewController
<UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate,
UIImagePickerControllerDelegate, UIAlertViewDelegate> {
	UIImageView *imageView;
	UITextField *nameField;
	UITextField *emailField;
	
	UITextField *currentField;
	CGRect returnFrame;
	
	PeopleViewController *delegate;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) IBOutlet UITextField *emailField;

+ (EditProfileViewController *)profileEditorWithDelegate:(PeopleViewController *)del;

- (IBAction)changePicture;
- (IBAction)save;
- (IBAction)cancel;

@end
